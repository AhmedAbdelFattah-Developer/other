import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';

final _formatter = CurrencyFormatter();

class GiftVoucherGridItem extends StatelessWidget {
  final GiftVoucher voucher;
  final void Function() onPress;
  final bool showQrCode;

  GiftVoucherGridItem(this.voucher, {this.onPress, this.showQrCode = false});

  @override
  Widget build(BuildContext context) {
    final expiredAt = DateTime.fromMillisecondsSinceEpoch(voucher.expiredAt);

    return GestureDetector(
      onTap: () {
        if (onPress == null) {
          Navigator.of(context).pushNamed(
            '/shops/show',
            arguments: <String, dynamic>{'id': voucher.shopId},
          );
        }

        onPress();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.white,
          image: voucher.hasPhotoPath
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      'https://u-win.shop/files/shops/${voucher.shopId}/${voucher.photoPath}'),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Color(0x3C000000),
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: CupertinoTheme.of(context).primaryColor.withAlpha(210),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                voucher.shopName, // TODO get shop
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          voucher.name,
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: showQrCode
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)))
                        : null,
                    child: showQrCode
                        ? QrImageView(
                            data: voucher.id,
                          )
                        : null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Gift Voucher',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      Text(
                        'Exp: ${expiredAt.day}/${expiredAt.month}/${expiredAt.year}',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ],
                  ),
                  Text(
                    '${_formatter.format(voucher.amount)}',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
