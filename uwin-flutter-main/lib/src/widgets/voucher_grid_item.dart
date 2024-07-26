import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uwin_flutter/src/blocs/scan_partner_qr_bloc.dart';
import 'package:uwin_flutter/src/dialogs/show_voucher_dialog.dart';
import '../models/voucher.dart';

class VoucherGridItem extends StatelessWidget {
  final Voucher voucher;
  final Function(Voucher) onPress;
  final bool showQrCode;
  final bool showOverlay;
  final bool useBackgroundImg;

  VoucherGridItem(
    this.voucher, {
    this.onPress,
    this.showQrCode = false,
    this.showOverlay = true,
    this.useBackgroundImg = true,
  });

  @override
  Widget build(BuildContext context) {
    final expiredAt = voucher.expiredAt;

    return GestureDetector(
      onTap: () {
        if (onPress == null) {
          showVoucherDialog(context, voucher);
          return;
        }

        onPress(voucher);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.white,
          image: useBackgroundImg
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
            color: showOverlay
                ? CupertinoTheme.of(context).primaryColor.withAlpha(210)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                voucher.shopName,
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
                          voucher.name ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  showQrCode
                      ? Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          child: QrImageView(
                            data: voucher.id,
                          ),
                        )
                      : const SizedBox(
                          width: 80.0,
                          height: 80.0,
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
                        'Voucher',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      Text(
                        'Exp: ${expiredAt.day}/${expiredAt.month}/${expiredAt.year}',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                      if (voucher.useVoucherCode)
                        Text(
                          'Quantity Remaining: ${voucher.qtyAvailable}',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                    ],
                  ),
                  Text(
                    'Rs ${voucher.amount}',
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
