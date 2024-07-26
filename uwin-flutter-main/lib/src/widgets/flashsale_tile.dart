import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uwin_flutter/src/widgets/popup_image.dart';

import '../models/flashsale.dart';

class FlashsaleTile extends StatelessWidget {
  final double colWidth;
  final double rowHeight;
  final EdgeInsets tileMargin;
  final Flashsale flashsale;
  final bool displayShopName;
  final bool enableTap;
  final formatter = new NumberFormat("#,##0.00", "en_US");
  final bool popupImage;

  FlashsaleTile({
    this.flashsale,
    this.colWidth = 136.0,
    this.rowHeight,
    this.tileMargin,
    this.displayShopName = true,
    this.enableTap = true,
    this.popupImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (enableTap) {
          Navigator.of(context).pushNamed(
            '/shops/show',
            arguments: <String, dynamic>{'id': flashsale.idShop},
          );
        }
        if (popupImage) {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return PopupImage(
                title: flashsale.name,
                src:
                    'https://u-win.shop/files/shops/${flashsale.idShop}/${flashsale.photoPathItem}',
              );
            },
          );
        }
      },
      child: Container(
        width: colWidth,
        height: rowHeight,
        margin: tileMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3C000000),
                    offset: Offset(2.0, 2.0),
                    blurRadius: 2.0,
                    spreadRadius: 1.0,
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: colWidth,
                height: rowHeight ?? colWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: new DecorationImage(
                    image: NetworkImage(
                        'https://u-win.shop/files/shops/${flashsale.idShop}/${flashsale.photoPathItem}'),
                    fit: BoxFit.scaleDown,
                  ),
                ),
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
                  padding: EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF59C4B8),
                    borderRadius: BorderRadius.all(
                      Radius.circular(3.0),
                    ),
                  ),
                  child: Text(
                    '-${flashsale.discountPercent} %',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Only ${flashsale.remainingNbSales} items left',
              style: TextStyle(
                color: Color(0xFF5F5F5F),
                fontSize: 12.0,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              '${flashsale.nameItem}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Rs ${formatter.format(flashsale.discountedItemPrice)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(3.0),
                    ),
                  ),
                  padding: EdgeInsets.all(3.0),
                ),
                SizedBox(
                  width: 3.0,
                ),
                Text(
                  'Rs ${formatter.format(flashsale.priceItem)}',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFF9F9F9F),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            displayShopName
                ? Text(
                    '${flashsale.nameShop}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F5F5F),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
