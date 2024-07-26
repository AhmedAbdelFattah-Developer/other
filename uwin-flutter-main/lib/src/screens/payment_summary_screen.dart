import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uwin_flutter/src/blocs/payment_summary_bloc.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/widgets/currency_number_format.dart';

const _footerHeight = 90.0;

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url,
        enableJavaScript: true, forceSafariVC: true, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

class PaymentSummaryScreen extends StatefulWidget {
  final SalesOrder so;
  final PaymentSummaryBloc bloc;
  final String successRedirect;

  PaymentSummaryScreen(this.bloc, this.so, {this.successRedirect});

  @override
  _PaymentSummaryScreenState createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  bool isDev = false;
  bool devSpinner = false;

  @override
  void initState() {
    assert(() {
      isDev = true;

      return true;
    }());
    widget.bloc.init(widget.so);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      child: Stack(
        children: <Widget>[
          SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  largeTitle: Text('Order Summary'),
                ),
                _buildTitle(context, 'Order Details'),
                _buildOrderDetails(context),
                _buildTitle(context, 'Order Items'),
                _buildItemList(context),
                SliverToBoxAdapter(child: SizedBox(height: _footerHeight)),
              ],
            ),
          ),
          _buildPayNowButton(context),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context) {
    final items = widget.so.orderedItems;

    return SliverToBoxAdapter(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index % 2 == 0) {
                final it = items[index ~/ 2];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 70.0,
                          height: 70.0,
                          decoration: it.photoPath != null
                              ? BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://u-win.shop/files/shops/${widget.so.shopId}/${it.photoPath}',
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 150.0,
                              child: Text(
                                '${it.product.name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('Quantity: ${it.quantity}',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),
                    CurrencyNumberFormat(number: it.total),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 78.0),
                  child: Divider(thickness: 2),
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              _buildOrderDetailsListTile(
                  context, 'Order #', Text(widget.so.id)),
              if (!widget.so.hasFreeShipping)
                Divider(height: 0.0, thickness: 2.0),
              if (!widget.so.hasFreeShipping)
                _buildOrderDetailsListTile(
                  context,
                  'Delivery Method',
                  Text(widget.so.shippingLabel),
                ),
              if (widget.so.itemsTotal != widget.so.total)
                Divider(height: 0.0, thickness: 2.0),
              if (widget.so.itemsTotal != widget.so.total)
                _buildOrderDetailsListTile(
                  context,
                  'Items total',
                  CurrencyNumberFormat(number: widget.so.itemsTotal),
                ),
              if (widget.so.hasHandlingFee)
                Divider(height: 0.0, thickness: 2.0),
              if (widget.so.hasHandlingFee)
                _buildOrderDetailsListTile(
                  context,
                  'Handling Fee',
                  CurrencyNumberFormat(number: widget.so.handlingFeeAmount),
                ),
              if (!widget.so.hasFreeShipping)
                Divider(height: 0.0, thickness: 2.0),
              if (!widget.so.hasFreeShipping)
                _buildOrderDetailsListTile(
                  context,
                  'Delivery',
                  CurrencyNumberFormat(number: widget.so.shippingCost),
                ),
              if (widget.so.hasVoucher) Divider(height: 0.0, thickness: 2.0),
              if (widget.so.hasVoucher)
                _buildOrderDetailsListTile(
                  context,
                  'Vouchers',
                  CurrencyNumberFormat(number: -1 * widget.so.voucherAmount),
                ),
              Divider(height: 0.0, thickness: 2.0),
              _buildOrderDetailsListTile(
                context,
                'Order total',
                CurrencyNumberFormat(number: widget.so.total),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildOrderDetailsListTile(
      BuildContext context, String title, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: const TextStyle(color: Colors.black54)),
            trailing,
          ]),
    );
  }

  Widget _buildPayNowButton(BuildContext context) {
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
        height: _footerHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: StreamBuilder<String>(
                stream: widget.bloc.paymentUrl,
                builder: (context, snapshot) {
                  if (isDev) {
                    return CupertinoButton(
                      color: CupertinoTheme.of(context).primaryColor,
                      disabledColor: Colors.black38,
                      onPressed: devSpinner
                          ? null
                          : () async {
                              setState(() {
                                devSpinner = true;
                              });
                              try {
                                await widget.bloc.forceComplete(widget.so);
                                await _showSuccessModal(context);
                              } catch (err) {
                                print('[payment_summary_screen] $err');
                              } finally {
                                setState(() {
                                  devSpinner = false;
                                });
                              }
                            },
                      child: devSpinner
                          ? CupertinoActivityIndicator()
                          : Text('PAY NOW'),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  }

                  return CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                    disabledColor: Colors.black38,
                    onPressed: snapshot.hasData
                        ? () async {
                            await _launchURL(snapshot.data);

                            widget.bloc.paymentState(widget.so.id).listen(
                              (state) async {
                                if (state == 'failed') {
                                  await closeWebView();
                                  await _showFailedModal(context);
                                }
                              },
                              onDone: () async {
                                await closeWebView();
                                await _showSuccessModal(context);
                              },
                              onError: (err) {
                                print(
                                  '[payment_summary_screen] Payment State Error',
                                );
                                print(err);

                                closeWebView();
                                // TODO notify user of error
                              },
                            );
                          }
                        : null,
                    child: Text('PAY NOW'),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Future<T> _showFailedModal<T>(BuildContext context) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text(
          'Payment Failed',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Payment could not be completed.',
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<T> _showSuccessModal<T>(BuildContext context) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text(
          'Order Confirm',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your order has been\nplaced successfully .\nA copy of your order\nhas been sent to you by email.',
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Okay'),
            onPressed: () {
              if (widget.successRedirect == null) {
                Navigator.of(context).pushReplacementNamed('/');
              } else {
                Navigator.of(context).pushReplacementNamed(
                  widget.successRedirect,
                  arguments: <String, dynamic>{'so': widget.so},
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
