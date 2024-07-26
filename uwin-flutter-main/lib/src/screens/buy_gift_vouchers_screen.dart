import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/buy_gift_voucher_bloc.dart';
import 'package:uwin_flutter/src/blocs/shop_voucher_bloc.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/widgets/voucher_grid_item.dart';

class BuyGiftVoucherScreen extends StatelessWidget {
  BuyGiftVoucherScreen({this.useBackgroundImg = true});

  static const String pageTitle = 'Buy Gift Vouchers';
  static const String route = '/buy-gift-vouchers';
  final bool useBackgroundImg;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BuyGiftVouchersBloc>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(BuyGiftVoucherScreen.pageTitle),
      ),
      child: SafeArea(
        child: StreamBuilder<List<GiftVoucher>>(
          stream: bloc.allGiftVouchers,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${snapshot.error}'),
              ));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            return Material(
              child: ListView.separated(
                  itemCount: 1,
                  separatorBuilder: (_, __) => SizedBox(
                        height: 16.0,
                      ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 182,
                        child: VoucherGridItem(
                          snapshot.data[index].toVoucher(),
                          showQrCode: false,
                          showOverlay: index % 2 == 0,
                          useBackgroundImg: useBackgroundImg,
                          onPress: (voucher) async {
                            final so = Provider.of<ShopVoucherBloc>(context)
                                .createSalesOrder(
                              voucher,
                              Shop(id: snapshot.data[index].shopId),
                            );
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
                      ),
                    );
                  }),
            );
          },
        ),
      ),
    );
  }
}
