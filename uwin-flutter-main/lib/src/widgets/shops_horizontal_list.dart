import 'package:flutter/material.dart';
import '../models/shop.dart';

class ShopsHorizontalList extends StatelessWidget {
  final List<Shop> shops = [
    Shop(
      id: '5bf6b5b55f6650066a6b262e',
      name: 'Test Shop 1',
      description:
          'Hi quality leather shoes shop\n\nOur product rage include:\n- Women Shoes\n- Men Shoes\n- Belt\n- Purse\n- Wallet\n- Safety shoes\n- Footwear',
      photoPath: [
        '1542896942174.jpg',
      ],
    ),
    Shop(
      id: '5bf6b5b55f6650066a6b262e',
      name: 'Test Shop 1',
      description:
          'Hi quality leather shoes shop\n\nOur product rage include:\n- Women Shoes\n- Men Shoes\n- Belt\n- Purse\n- Wallet\n- Safety shoes\n- Footwear',
      photoPath: [
        '1542896942174.jpg',
      ],
    ),
    Shop(
      id: '5bf6b5b55f6650066a6b262e',
      name: 'Test Shop 1',
      description:
          'Hi quality leather shoes shop\n\nOur product rage include:\n- Women Shoes\n- Men Shoes\n- Belt\n- Purse\n- Wallet\n- Safety shoes\n- Footwear',
      photoPath: [
        '1542896942174.jpg',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      height: 150.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shops.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 115.0,
              margin: EdgeInsets.only(
                left: index == 0 ? 20.0 : 5.0,
                right: index + 1 == shops.length ? 20.0 : 5.0,
              ),
              // margin: EdgeInsets.symmetric(
              //   horizontal: index == 0 || index+1 == shops.length ? 20.0 : 5.0,
              // ),
              height: 205.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 115.0,
                    height: 115.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://u-win.shop/files/shops/5bf6b5b55f6650066a6b262e/1542896942174.jpg'),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    shops[index].name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFFFE9015),
                    ),
                  ),
                  Text(
                    shops[index].description.replaceAll('\n', ' '),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
