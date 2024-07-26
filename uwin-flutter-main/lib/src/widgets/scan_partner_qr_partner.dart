import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';

import '../blocs/scan_partner_qr_bloc.dart';

class ScanPartnerQrButton extends StatelessWidget {
  static const btnLabel = 'Scan Shop QR';

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Text(
          btnLabel,
          style: TextStyle(
            fontSize: 10.0,
            color: Colors.white,
          ),
        ),
      ),
      onPressed: () async {
        final bloc = Provider.of<ScanPartnerQrBloc>(context, listen: false);
        try {
          final authState = await AuthBlocProvider.of(context).authState.first;
          if (authState != 'completed') {
            try {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Cannot Scan Shop QR Code'),
                  content: const Text(
                    'You must complete your profile to be able to scan Shop QR Code',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            } catch (err) {
              debugPrint('$err');
            }

            return;
          }

          final shopId = await bloc.scan(context);
          final geolocation = await bloc.getGeolocation();
          Navigator.of(context).pushNamed(
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
                style: TextStyle(color: Colors.red),
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
    );
    //   },
    // );
  }
}
