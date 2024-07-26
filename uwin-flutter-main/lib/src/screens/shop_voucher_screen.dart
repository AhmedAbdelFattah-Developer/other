import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/providers/shop_voucher_bloc_provider.dart';

import '../models/shop.dart';
import '../models/voucher.dart';
import '../widgets/voucher_grid_item.dart';

class ShopVoucherScreen extends StatefulWidget {
  final Shop shop;

  ShopVoucherScreen(this.shop);

  @override
  _ShopVoucherScreenState createState() => _ShopVoucherScreenState();
}

class _ShopVoucherScreenState extends State<ShopVoucherScreen> {
  bool showSpinner = false;

  payNow(BuildContext context, Voucher voucher) async {
    // print('[shop_voucher_screen] payNow called.');
    // final bloc = ShopVoucherBlocProvider.of(context);

    // setState(() {
    //   showSpinner = true;
    // });
    // final client = http.Client();
    // try {
    //   final nonce = await bloc.getNonce(client);
    //   final braintreePayment = new BraintreePayment();
    //   setState(() {
    //     showSpinner = false;
    //   });
    //   final data = await braintreePayment.showDropIn(
    //       nonce: nonce, amount: '${voucher.amount}', enableGooglePay: false);

    //   print(
    //       '[shop_voucher_screen] >>>>>>>>>>>>>>>>>>>>>>>> braintreePayment data: ${data.runtimeType}');

    //   // if (Platform.isIOS) {
    //   //   print(
    //   //       '[shop_voucher_screen] token.startsWith: ${(data as String).startsWith('token')}');
    //   //   if ((data as String).startsWith('token')) {
    //   //     setState(() {
    //   //       showSpinner = true;
    //   //     });

    //   //     await bloc.checkout(client, voucher, data);
    //   //   } else {
    //   //     throw data;
    //   //   }
    //   // } else {
    //   if (data['status'] == 'success') {
    //     setState(() {
    //       showSpinner = true;
    //     });

    //     final res = await bloc.checkout(client, voucher, data['paymentNonce']);
    //     print('[shop_voucher_screen] ############## $res');
    //   } else {
    //     throw data;
    //   }
    //   // }
    // } finally {
    //   client.close();
    // }
  }

  @override
  Widget build(BuildContext pcontext) {
    final bloc = ShopVoucherBlocProvider.of(context);

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('Gift Vouchers'),
      ),
      child: showSpinner
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : StreamBuilder(
              stream: bloc.getVouchers(widget.shop),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        child: ListTile(
                          title: Text('Error'),
                          subtitle: Text('${snapshot.error}'),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.only(top: 100.0, left: 20.0, right: 20.0),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 20.0);
                  },
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 182,
                      child: VoucherGridItem(
                        snapshot.data[index],
                        showQrCode: false,
                        showOverlay: index % 2 == 0,
                        onPress: (voucher) async {
                          final so =
                              bloc.createSalesOrder(voucher, widget.shop);
                          Navigator.of(context).pushNamed(
                            '/shops/shipping-address',
                            arguments: <String, dynamic>{
                              'so': so,
                              'title': 'Billing Address',
                              'successRedirect': '/shops/vouchers/success',
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
