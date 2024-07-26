import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/scan_partner_qr_bloc.dart';
import 'package:uwin_flutter/src/models/voucher.dart';

void showVoucherDialog(BuildContext context, Voucher voucher) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(voucher.name),
      actions: [
        CupertinoDialogAction(
          child: Text(
            'Redeem',
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            final bloc = Provider.of<ScanPartnerQrBloc>(context, listen: false);
            try {
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.pop();
              }
              final shopId = voucher.shopId == '5fd890075f66506c6557c203'
                  ? voucher.shopId
                  : await bloc.scan(context);
              final geolocation = await bloc.getGeolocation();
              nav.pushNamed(
                '/shop-transaction',
                arguments: <String, dynamic>{
                  'shopId': shopId,
                  'geolocation': geolocation,
                },
              );
              // }
            } catch (err) {
              print('[home_screen] Could not find shop');
              print(err);

              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text(
                    'Unexpected Error',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  content: Text(
                    'An unexpected error has occurred.\nPlease check your internet connection or camera permission',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Ok'),
                      onPressed: () {
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
        CupertinoDialogAction(
          child: Text('Go to ${voucher.shopName}'),
          onPressed: () {
            Navigator.of(context).pushNamed(
              '/shops/show',
              arguments: <String, dynamic>{'id': voucher.shopId},
            );
          },
        ),
        CupertinoDialogAction(
          child: Text('Close'),
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            }
          },
        ),
      ],
    ),
  );
}
