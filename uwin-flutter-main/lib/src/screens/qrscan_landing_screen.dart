import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/models/shop.dart';

class QrscanLandingScreen extends StatelessWidget {
  QrscanLandingScreen(this.shop);

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        middle: Text(shop.name),
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * .18,
                            ),
                            child: Image.asset(
                              'assets/category_icons/food.png',
                              width: double.infinity,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Restaurant Menu',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .navLargeTitleTextStyle
                                .copyWith(fontSize: 22.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(shop.description),
                          SizedBox(height: 16.0),
                          Container(
                            width: double.infinity,
                            child: CupertinoButton(
                              child: Text('Open Menu'),
                              onPressed: () {},
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.store),
                          title: Text('View Shop'),
                          subtitle: Text('Shop description and location'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.check_circle_outline),
                          title: Text('Redeem'),
                          subtitle:
                              Text('Redeem your voucher, coupon and flashsale'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
