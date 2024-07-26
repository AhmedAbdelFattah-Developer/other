import 'package:flutter/cupertino.dart';
import '../models/flashsale.dart';
import 'flashsale_tile.dart';

class FlashSalesFavorite extends StatelessWidget {
  final List<Flashsale> flashsaleList;

  FlashSalesFavorite(this.flashsaleList);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0,
      margin: EdgeInsets.only(bottom: 5.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: flashsaleList.length,
        itemBuilder: (BuildContext context, int index) {
          final margin = index == 0
              ? EdgeInsets.only(left: 20.0, right: 10.0)
              : EdgeInsets.only(right: 10.0);

          return FlashsaleTile(
            tileMargin: margin,
            flashsale: flashsaleList[index],
          );
        },
      ),
    );
  }
}