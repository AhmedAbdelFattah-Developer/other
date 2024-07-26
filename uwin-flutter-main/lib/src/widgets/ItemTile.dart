import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/widgets/currency_number_format.dart';
import 'package:uwin_flutter/src/widgets/popup_image.dart';
import '../models/item.dart';

class ItemTile extends StatelessWidget {
  final bool points;
  final Item item;
  final String shopId;
  final bool popupImage;

  ItemTile(this.shopId, this.item,
      {this.popupImage = false, this.points = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: CupertinoTheme.of(context).primaryColor,
    );

    return GestureDetector(
      onTap: () {
        if (popupImage) {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return PopupImage(
                  title: item.name,
                  src:
                      'https://u-win.shop/files/shops/$shopId/${item.photoPath}',
                );
              });
        } else {
          Navigator.of(context).pushNamed(
            '/shops/item',
            arguments: <String, dynamic>{
              'item': Item(
                id: item.id,
                name: item.name,
                price: item.price,
                shopId: shopId,
                description: item.description,
                photoPath: item.photoPath,
              ),
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x3C000000),
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5.0),
                ),
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: NetworkImage(
                    'https://u-win.shop/files/shops/$shopId/${item.photoPath}',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15.0),
                  points
                      ? Text('${item.price.round()} Points', style: style)
                      : CurrencyNumberFormat(
                          number: (item.price * 100).round(),
                          style: style,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
