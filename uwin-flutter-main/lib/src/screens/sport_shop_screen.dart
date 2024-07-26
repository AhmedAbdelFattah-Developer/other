import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/sport_shop_bloc.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/models/shop_ext.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SportShopScreen extends StatelessWidget {
  final Shop shop;

  SportShopScreen({Key key, @required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Localizations(
        locale: const Locale('en', 'GB'),
        delegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(shop.shopTypeName),
          ),
          child: SafeArea(
            child: SportShopContent(shop: shop),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class SportShopContent extends StatelessWidget {
  final Shop shop;

  const SportShopContent({
    Key key,
    @required this.shop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = CupertinoTheme.of(context);

    return StreamBuilder<List<TabData>>(
        stream: Provider.of<SportShopBloc>(context, listen: false)
            .getTabsData(shop.id),
        builder: (context, snapshot) {
          return DefaultTabController(
            length: snapshot.hasData ? snapshot.data.length : 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    'https://u-win.shop/files/shops/${shop.id}/${shop.bannerUrl}',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      shop.name,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle,
                    ),
                  ),
                  snapshot.hasData
                      ? Container(color: Colors.grey.shade100, height: 1)
                      : Container(),
                  snapshot.hasData
                      ? Container(
                          child: TabBar(
                            tabs: tabsDataToNavigation(snapshot.data),
                            labelPadding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                            labelColor: theme.primaryColor,
                            indicatorColor: theme.primaryColor,
                            unselectedLabelColor: theme
                                .textTheme.navTitleTextStyle.color
                                .withAlpha(120),
                          ),
                          alignment: Alignment.center,
                          width: double.infinity,
                        )
                      : Container(),
                  snapshot.hasData
                      ? Container(height: 8.0, color: Colors.grey.shade400)
                      : Container(),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: Builder(
                      builder: (context) {
                        if (snapshot.hasError) {
                          return Center(child: Text('${snapshot.error}'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CupertinoActivityIndicator());
                        }

                        return TabBarView(
                          key: Key('sportShopTabs'),
                          children: snapshot.data
                              .map(
                                (e) => WebView(
                                    gestureNavigationEnabled: false,
                                    initialUrl: e.url.replaceFirst(
                                        ':width', width.toString())),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

@visibleForTesting
List<Text> tabsDataToNavigation(List<TabData> tabsData) =>
    tabsData.map((val) => Text(val.label)).toList();
