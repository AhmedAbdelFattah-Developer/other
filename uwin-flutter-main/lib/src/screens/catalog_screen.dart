import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/providers/catalog_bloc_provider.dart';
import 'package:uwin_flutter/src/models/item.dart';
import 'package:uwin_flutter/src/models/product_item.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/widgets/ItemTile.dart';
import 'dart:math';

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);

const Border _kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);

class CatalogDialog extends StatelessWidget {
  final Shop shop;

  CatalogDialog(this.shop);

  @override
  Widget build(BuildContext context) {
    final bloc = CatalogBlocProvider.of(context);

    return CupertinoPageScaffold(
      child: StreamBuilder<Map<String, Map<String, List<ProductItem>>>>(
        stream: bloc.productItemByCategory,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              child: CupertinoActivityIndicator(),
              alignment: Alignment.center,
            );
          }

          return _CatalogDialogContent(shop, snapshot.data);
        },
      ),
    );
  }
}

class _CatalogDialogContent extends StatefulWidget {
  final Map<String, Map<String, List<ProductItem>>> map;
  final Shop shop;

  _CatalogDialogContent(this.shop, this.map);

  @override
  __CatalogDialogContentState createState() => __CatalogDialogContentState();
}

class __CatalogDialogContentState extends State<_CatalogDialogContent> {
  String tabIndex;

  @override
  void initState() {
    tabIndex = widget.map.keys.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sliverList = <Widget>[];
    for (var subcatEntry in widget.map[tabIndex].entries) {
      if (widget.map[tabIndex].keys.length > 1) {
        sliverList.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                subcatEntry.key,
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
            ),
          ),
        );
      }
      sliverList.add(
        __buildItemGrid(
          context,
          widget.shop.id,
          subcatEntry.value.map((e) => e.toItem()).toList(),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            padding: EdgeInsetsDirectional.zero,
            border: null,
            middle: Text(widget.shop.name),
            largeTitle: Text('Catalog'),
          ),
          _buildTabBar(context),
          ...sliverList,
        ],
      ),
    );

    // final slivers = <Widget>[_DialogNavigationBar(shop.name)];

    // if (catalog.flashsales.length > 0) {
    //   slivers.add(
    //     SliverToBoxAdapter(
    //       child: _buildTitle('Flashsales'),
    //     ),
    //   );
    //   slivers.add(_buildFlashsalesGrid(context));
    // }

    // if (catalog.items.length > 0) {
    //   slivers.add(
    //     SliverToBoxAdapter(
    //       child: _buildTitle('All items'),
    //     ),
    //   );
    //   slivers.add(__buildItemGrid(context, shop.id));
    // } else {
    //   slivers.add(
    //     SliverFillRemaining(
    //       child: Center(
    //         child: Text(
    //           'No product available',
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // return CustomScrollView(
    //   slivers: slivers,
    // );
  }

  Widget __buildItemGrid(
    BuildContext context,
    String shopId,
    List<Item> items,
  ) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 200).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 245;
    final tileAspectRatio = tileWidth / tileHeight;

    return SliverPadding(
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 30.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: tileAspectRatio,
        ),
        delegate: SliverChildListDelegate(items
            .map<Widget>((Item it) => ItemTile(
                  shopId,
                  it,
                  popupImage: true,
                ))
            .toList()),
      ),
      padding: EdgeInsets.all(16.0),
    );
  }

  Widget _buildTabBar(BuildContext context) {
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
            itemCount: widget.map.keys.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final primaryColor = CupertinoTheme.of(context).primaryColor;
              final keys = List<String>.from(widget.map.keys);
              final isActive = keys[index] == tabIndex;

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    tabIndex = keys[index];
                  });
                },
                child: Container(
                  decoration: isActive
                      ? BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: primaryColor)),
                        )
                      : null,
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  child: Center(
                    child: Text(List<String>.from(widget.map.keys)[index],
                        style: TextStyle(
                          color: isActive
                              ? primaryColor
                              : CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color,
                        )),
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
