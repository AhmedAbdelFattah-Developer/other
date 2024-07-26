import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/shop_voucher_success_bloc.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/models/shop.dart';

final _formatter = CurrencyFormatter();

class ShopVoucherSuccessScreen extends StatelessWidget {
  final SalesOrder so;

  ShopVoucherSuccessScreen(this.so);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('Gift Vouchers'),
      ),
      child: StreamBuilder<Shop>(
          stream:
              Provider.of<ShopVoucherSuccessBloc>(context).getShop(so.shopId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            return SingleChildScrollView(
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'Success',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            subtitle: Text(
                                'Thank you for buying the voucher of ${_formatter.format(so.total)}. You may send the voucher as a gift or redeem it at ${snapshot.data.name}'),
                          ),
                          ButtonBarTheme(
                            data: ButtonBarThemeData(),
                            // make buttons use the appropriate styles for cards
                            child: ButtonBar(
                              children: <Widget>[
                                _SendButton(so.id),
                                CupertinoButton(
                                  child: const Text('Keep'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      '/my-wins',
                                      arguments: <String, dynamic>{
                                        'tab': 'my_voucher',
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // child: Column(
                    //   children: <Widget>[
                    //     _buildTitle('Success'),
                    //     Text(
                    //         'Thank you for buying the voucher of ${voucher.amount}. You may send the voucher as a gift or redeem it at ${voucher.shopName}'),
                    //   ],
                    // ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class _SendButton extends StatefulWidget {
  _SendButton(this.salesOrderId);

  final String salesOrderId;

  @override
  __SendButtonState createState() => __SendButtonState();
}

class __SendButtonState extends State<_SendButton> {
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: showSpinner
          ? CupertinoActivityIndicator()
          : const Text('Send as gift'),
      onPressed: showSpinner
          ? null
          : () {
              final bloc = Provider.of<ShopVoucherSuccessBloc>(context);
              setState(() {
                showSpinner = true;
              });
              bloc.getGiftVoucher(widget.salesOrderId).take(1).listen((gv) {
                Navigator.of(context).pushReplacementNamed(
                  '/send-gift-voucher',
                  arguments: <String, dynamic>{'giftVoucher': gv},
                );
                showSpinner = false;
              }, onError: (err) {
                print('[shop_voucher_success_screen] Error: $err');
                showCupertinoDialog(
                  context: context,
                  builder: (dialogContext) => CupertinoAlertDialog(
                      title: new Text("Error"),
                      content: new Text("$err"),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: new Text("Close"),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        )
                      ]),
                );
                showSpinner = false;
              });
            },
    );
  }
}
