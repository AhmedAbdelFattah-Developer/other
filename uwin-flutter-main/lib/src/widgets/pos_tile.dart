import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uwin_flutter/src/models/shop.dart';

import '../models/pos.dart';
import '../blocs/providers/shop_bloc_provider.dart';
import '../screens/shop_screen.dart';

class PosTile extends StatelessWidget {
  final Pos pos;
  final String name;

  PosTile(this.pos, {this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final bloc = ShopBlocProvider.of(context);
              bloc.fetch(pos.shop.id);

              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return ShopScreen();
                  },
                ),
              );
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5.0),
                ),
                image: pos.shop.photoPath.length > 0
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://u-win.shop/files/shops/${pos.shop.id}/${pos.shop.photoPath.first}',
                        ),
                      )
                    : pos.photoPath.length > 0
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              'https://u-win.shop/files/shops/${pos.shop.id}/${pos.photoPath.first}',
                            ),
                          )
                        : null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name ?? pos.name,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pos.cityName,
                  style: const TextStyle(fontSize: 12.0),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5.0),
                Text(
                  pos.address,
                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20.0),
                if (pos.tel != '0' && pos.tel != '1')
                  GestureDetector(
                    onTap: () => _launchPhone(pos.tel),
                    child: Text(
                      'Call: ${pos.tel}',
                      style: TextStyle(
                        color: CupertinoTheme.of(context).primaryColor,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

_launchPhone(String phone) async {
  final url = 'tel:${phone.replaceAll(' ', '-')}';

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class ShopTile extends StatelessWidget {
  final Shop shop;
  final String name;

  ShopTile(this.shop, {this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/shops/show',
                  arguments: <String, dynamic>{
                    'id': shop.id,
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(5.0),
                  ),
                  image: shop.photoPath.length > 0
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'https://u-win.shop/files/shops/${shop.id}/${shop.photoPath.first}',
                          ),
                        )
                      : shop.photoPath.length > 0
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://u-win.shop/files/shops/${shop.id}/${shop.photoPath.first}',
                              ),
                            )
                          : null,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/shops/show',
                arguments: <String, dynamic>{
                  'id': shop.id,
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name ?? shop.name,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
