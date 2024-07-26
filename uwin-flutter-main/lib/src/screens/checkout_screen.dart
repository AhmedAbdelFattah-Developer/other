import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/item.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/widgets/currency_number_format.dart';
import 'package:uwin_flutter/src/widgets/popup_image.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/blocs/checkout_bloc.dart';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);
const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

final _currencyFormatter = CurrencyFormatter();

class CheckoutScreen extends StatefulWidget {
  final CheckoutBloc bloc;
  final String shopId;

  CheckoutScreen(this.bloc, this.shopId);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    widget.bloc.init(widget.shopId);
    _scrollController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CheckoutBloc>(context);

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      child: StreamBuilder<SalesOrder>(
        stream: bloc.salesOrder,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: <Widget>[
                _buildNav(context),
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${snapshot.error}'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (!snapshot.hasData) {
            return CustomScrollView(
              slivers: <Widget>[
                _buildNav(context),
                SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              ],
            );
          }

          return Stack(
            children: <Widget>[
              _buildContent(context, snapshot.data),
              _buildBottomBar(context, snapshot.data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SalesOrder so) {
    return StreamBuilder<CheckoutStep>(
      stream: Provider.of<CheckoutBloc>(context).step,
      builder: (context, snapshot) {
        if (snapshot.data == CheckoutSteps.delivery) {
          return _buildDeliverStep(context, so);
        }

        return _buildItemsStep(context, so);
      },
    );
  }

  Widget _buildDeliverStep(BuildContext context, SalesOrder so) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          _buildNav(context, defaultBack: false),
          _buildFormHeader(context, so),
          _buildNetTotal(context, so.itemsTotal),
          SliverToBoxAdapter(child: SizedBox(height: 20.0)),
          _buildHandlingFee(context, so),
          _buildVoucherList(context, so),
          _buildDeliveryList(context, so),
          SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }

  Widget _buildVoucherList(BuildContext context, SalesOrder so) {
    return StreamBuilder<Map<String, Voucher>>(
        stream: widget.bloc.vouchers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('[checkout_screen] Error: ${snapshot.error}');
            return SliverToBoxAdapter(
              child: Text('An unexpected error occured'),
            );
          }

          if (!snapshot.hasData) {
            return SliverToBoxAdapter(child: Container());
          }

          if (snapshot.data.length == 0) {
            return SliverToBoxAdapter(child: Container());
          }

          return SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(
                    'Vouchers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ..._buildVoucherListTiles(context, snapshot.data, so.vouchers),
                SizedBox(height: 20.0),
              ],
            ),
          );
        });
  }

  List<Widget> _buildVoucherListTiles(
    BuildContext context,
    Map<String, Voucher> vouchers,
    Map<String, int> selectedVouchers,
  ) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return vouchers.entries
        .map<Widget>(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ListTile(
                  onTap: () {
                    widget.bloc.toggleVoucher(entry.value);
                  },
                  leading: Icon(
                    selectedVouchers.containsKey(entry.key)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: selectedVouchers.containsKey(entry.key)
                        ? primaryColor
                        : null,
                  ),
                  title: Text(
                    entry.value.name,
                    style: TextStyle(
                        color: selectedVouchers.containsKey(entry.key)
                            ? primaryColor
                            : null),
                  ),
                  subtitle: Text(entry.value.shopName),
                  trailing: CurrencyNumberFormat(
                    number: entry.value.amount * 100,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildItemsStep(BuildContext context, SalesOrder so) {
    return StreamBuilder(
      stream: Provider.of<CheckoutBloc>(context).currentCategory,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CupertinoActivityIndicator());
        }

        return StreamBuilder<Map<String, bool>>(
          stream: widget.bloc.itemsDetails,
          builder: (context, snapshot2) {
            if (!snapshot2.hasData || snapshot2.hasError) {
              return Container();
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                _buildNav(context),
                _buildCategoryNav(context, so.categories),
                _buildItemList(context, so, snapshot.data, snapshot2.data),
                SliverToBoxAdapter(child: SizedBox(height: 128.0)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNetTotal(BuildContext context, int nettotal) {
    const style = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0x33000000)),
            bottom: BorderSide(color: Color(0x33000000)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Net Total', style: style),
            CurrencyNumberFormat(
              number: nettotal,
              style: style,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryNav(BuildContext context, List<String> categories) {
    final bloc = Provider.of<CheckoutBloc>(context);

    return StreamBuilder<String>(
      stream: bloc.currentCategory,
      builder: (context, snapshot) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 60.0,
            maxHeight: 60.0,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                border: _kDefaultNavBarBorder,
              ),
              child: ListView.builder(
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isActive = cat == snapshot.data;
                  final primaryColor = CupertinoTheme.of(context).primaryColor;

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _scrollController.jumpTo(0.0);
                      bloc.changeCategory(cat);
                    },
                    child: Container(
                      decoration: isActive
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: primaryColor)),
                            )
                          : null,
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8.0),
                      child: Center(
                        child: Text(
                          cat.isNotEmpty ? cat : 'Other',
                          style: isActive
                              ? TextStyle(
                                  color: primaryColor,
                                )
                              : CupertinoTheme.of(context).textTheme.textStyle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormHeader(BuildContext context, SalesOrder so) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0x33000000)),
            bottom: BorderSide(color: Color(0x33000000)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              radius: 30.0,
              child: Icon(CupertinoIcons.shopping_cart, size: 30.0),
            ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Order Total',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                CurrencyNumberFormat(
                  number: so.total,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Provider.of<CheckoutBloc>(context)
                      .changeStep(CheckoutSteps.items),
                  child: Row(
                    children: <Widget>[
                      Icon(CupertinoIcons.pencil),
                      SizedBox(width: 8.0),
                      Text('Modify your order'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CupertinoSliverNavigationBar _buildNav(BuildContext context,
      {bool defaultBack = true}) {
    final bloc = Provider.of<CheckoutBloc>(context);

    return CupertinoSliverNavigationBar(
      // automaticallyImplyLeading: automaticallyImplyLeading,
      leading: defaultBack
          ? null
          : CupertinoNavigationBarBackButton(
              onPressed: () => bloc.changeStep(CheckoutSteps.items),
            ),
      padding: EdgeInsetsDirectional.zero,
      border: null,
      middle: StreamBuilder<Shop>(
          stream: bloc.shop,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return Container();
            }

            return Text(snapshot.data.name);
          }),
      largeTitle: Text('Your Cart'),
    );
  }

  Widget _buildHandlingFee(BuildContext context, SalesOrder so) {
    if (!so.handlingFeeEnabled) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text(
                  'Handling Fee',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'No handling fee for order above ${_currencyFormatter.format(so.noHandlingFeeThreshold)}',
                ),
                trailing: CurrencyNumberFormat(
                  number: so.handlingFeeAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    decoration: so.hasHandlingFee || so.itemsTotal == 0
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    SalesOrder so,
    String cat,
    Map<String, bool> itemsDetails,
  ) {
    final list = <Widget>[SizedBox(height: 15.0)];
    final map = so.groupBySubcategory(cat);
    for (final grp in map.keys) {
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            grp.isNotEmpty ? grp : 'Other',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
        ),
      );
      for (final it in map[grp]) {
        list.add(_buildListDetails(context, so, it, itemsDetails));
      }
      list.add(SizedBox(height: 25.0));
    }
    list.add(SizedBox(height: 15.0));

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return list[index];
    }, childCount: list.length));
  }

  Widget _buildListDetails(
    BuildContext context,
    SalesOrder so,
    SalesOrderItem it,
    Map<String, bool> itemsDetails,
  ) {
    return _buildListItemTile(
      context,
      so,
      it,
      itemsDetails,
      it.hasDetails && itemsDetails[it.productId] == true,
    );
  }

  Widget _buildListItemTile(
    BuildContext context,
    SalesOrder so,
    SalesOrderItem it,
    Map<String, bool> items,
    bool showDetails,
  ) {
    final theme = CupertinoTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildItemImage(context, so, it),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            it.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3.0),
                                  ),
                                  color: it.product.hasNormalPrice
                                      ? theme.primaryColor
                                      : Colors.white,
                                ),
                                child: CurrencyNumberFormat(
                                  number: it.unitPrice,
                                  style: TextStyle(
                                    color: it.product.hasNormalPrice
                                        ? Colors.white
                                        : theme.primaryColor,
                                  ),
                                ),
                              ),
                              if (it.product.hasNormalPrice)
                                SizedBox(width: 8.0),
                              if (it.product.hasNormalPrice)
                                CurrencyNumberFormat(
                                  number: it.product.ext.normalPrice,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    onPressed: () {
                      widget.bloc.toggleItemsDetail(items, it.productId);
                    },
                    child: Transform.rotate(
                      angle: pi / 2 * (showDetails ? 1 : -1),
                      child: Icon(
                        CupertinoIcons.left_chevron,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (!it.isAvailable)
                    Container(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Out of stock',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (it.quantity == 0 && it.isAvailable)
                    Container(
                      alignment: Alignment.topRight,
                      child: OutlinedButton(
                        child: Text(
                          'Add to cart',
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        ),
                        onPressed: () {
                          widget.bloc.increment(it.product);
                        },
                      ),
                    ),
                  if (it.quantity > 0 && it.isAvailable)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 108.0,
                        padding: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                          border: Border.all(color: theme.primaryColor),
                        ),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                widget.bloc.decrement(it.product);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 25.0,
                                height: 25.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: theme.primaryColor)),
                                child: Text(
                                  '-',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 40.0,
                              child: Text('${it.quantity}'),
                            ),
                            GestureDetector(
                              onTap: it.canAddQuantity()
                                  ? () {
                                      widget.bloc.increment(it.product);
                                    }
                                  : null,
                              child: Container(
                                alignment: Alignment.center,
                                width: 25.0,
                                height: 25.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: it.canAddQuantity()
                                        ? theme.primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: it.canAddQuantity()
                                        ? theme.primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (showDetails) Text(it.product.description),
              if (showDetails) SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(
    BuildContext context,
    SalesOrder so,
    SalesOrderItem it,
  ) {
    return GestureDetector(
      onTap: () async {
        await _showImageDialog(
          context,
          it.product.name,
          'https://u-win.shop/files/shops/${so.shopId}/${it.photoPath}',
        );
      },
      child: Container(
        width: 65.0,
        height: 65.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFCCCCCC), width: 0.0),
          borderRadius: BorderRadius.circular(5.0),
          image: it.photoPath == null
              ? null
              : DecorationImage(
                  fit: BoxFit.contain,
                  image: NetworkImage(
                    'https://u-win.shop/files/shops/${so.shopId}/${it.photoPath}',
                  ),
                ),
        ),
      ),
    );
  }

  Future<T> _showImageDialog<T>(
      BuildContext context, String title, String src) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return PopupImage(title: title, src: src);
      },
    );
  }

  Widget _buildDeliveryList(BuildContext context, SalesOrder so) {
    return StreamBuilder<Map<Item, bool>>(
      stream: Provider.of<CheckoutBloc>(context).logisticProvidersItemsMap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Text('${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildListDelegate(
            [
              ListTile(
                title: Text(
                  'Delivery Provider',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (so.freeShippingEnabled) _buildFreeDeliveryTile(context, so),
              if (!so.hasFreeShipping)
                ..._buildDeliveryListTiles(context, snapshot.data),
              SizedBox(height: 20.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeDeliveryTile(BuildContext context, SalesOrder so) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: ListTile(
            title: Text('Free Shipping'),
            subtitle: Text(
              'Free Shipping for order abover ${_currencyFormatter.format(so.freeShippingThreshold)}',
            ),
            trailing: so.hasFreeShipping
                ? Text('Free', style: TextStyle(color: Colors.green))
                : null,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDeliveryListTiles(
      BuildContext context, Map<Item, bool> itemsMap) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return itemsMap.entries
        .map<Widget>(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: ListTile(
                  onTap: () =>
                      Provider.of<CheckoutBloc>(context).setShipping(entry.key),
                  leading: Icon(
                    entry.value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: entry.value ? primaryColor : null,
                  ),
                  title: Text(
                    entry.key.name,
                    style: TextStyle(color: entry.value ? primaryColor : null),
                  ),
                  subtitle: Text(entry.key.description),
                  trailing: CurrencyNumberFormat(
                    number: entry.key.priceCurrency,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildBottomBar(BuildContext context, SalesOrder so) {
    final bloc = Provider.of<CheckoutBloc>(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0x4C000000),
              width: 0.0, // One physical pixel.
              style: BorderStyle.solid,
            ),
          ),
        ),
        height: 118.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 15.0,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  StreamBuilder<CheckoutStep>(
                      stream: widget.bloc.step,
                      builder: (context, snapshot) {
                        return CurrencyNumberFormat(
                            number: snapshot.data == CheckoutSteps.items
                                ? so.itemsTotal
                                : so.total,
                            style: TextStyle(fontWeight: FontWeight.bold));
                      }),
                ],
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: StreamBuilder<CheckoutStep>(
                    stream: bloc.step,
                    builder: (context, snapshot) {
                      return CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        disabledColor: Colors.black38,
                        onPressed: bloc.isValid(so, snapshot.data) ||
                                (snapshot.data == CheckoutSteps.items &&
                                    so.itemsTotal > 0)
                            ? () async {
                                // if (!bloc.isValid(so, snapshot.data)) {
                                if (snapshot.data == CheckoutSteps.items) {
                                  bloc.changeStep(CheckoutSteps.delivery);
                                } else {
                                  final val =
                                      await Provider.of<CheckoutBloc>(context)
                                          .checkout(so);
                                  Navigator.of(context).pushNamed(
                                    '/shops/shipping-address',
                                    arguments: <String, dynamic>{'so': val},
                                  );
                                }
                              }
                            : null,
                        child: Text('CHECKOUT'),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDetails extends StatefulWidget {
  final String details;
  final buttonTextStyle = const TextStyle(
    color: Colors.black87,
    fontSize: 14.0,
  );

  _AnimatedDetails({@required this.details});

  @override
  __AnimatedDetailsState createState() => __AnimatedDetailsState();
}

class __AnimatedDetailsState extends State<_AnimatedDetails> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (isOpen) Text(widget.details),
        CupertinoButton(
            padding: EdgeInsets.zero,
            child: Row(
              children: <Widget>[
                Transform.rotate(
                  angle: pi / 2 * (isOpen ? 1 : -1),
                  child: Icon(
                    CupertinoIcons.left_chevron,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('${isOpen ? 'Hide' : 'Show'} Details',
                    style: widget.buttonTextStyle),
              ],
            ),
            onPressed: () {
              setState(() {
                isOpen = !isOpen;
              });
            }),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
