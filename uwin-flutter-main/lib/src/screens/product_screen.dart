import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/widgets/currency_number_format.dart';
import '../models/item.dart';

class ProductScreen extends StatelessWidget {
  final Item item;

  ProductScreen(this.item);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.network(
                'https://u-win.shop/files/shops/${item.shopId}/${item.photoPath}',
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                      child: CurrencyNumberFormat(
                        symbol: 'Points ',
                        number: item.priceCurrency,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.description ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
