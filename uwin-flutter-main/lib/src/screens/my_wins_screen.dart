import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/my_wins_menu_item.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';

import '../blocs/providers/flashsells_bloc_provider.dart';
import '../blocs/providers/my_wins_bloc_provider.dart';
import '../models/coupon.dart';
import '../models/flashsale.dart';
import '../widgets/app_tab_bar.dart';

final _formatter = CurrencyFormatter(symbol: '');

class MyWinsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          StreamBuilder<List<MyWinsMenuItem>>(
              stream: MyWinsBlocProvider.of(context).menuItems,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                return CustomScrollView(
                  slivers: <Widget>[
                    CupertinoSliverNavigationBar(
                      largeTitle: Text('My Wins'),
                      trailing: ScanPartnerQrButton(),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        snapshot.data
                            .map(
                              (it) => _buildItem(context, it.title,
                                  _buildItemCount(context, it.id), it.imageUrl,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/my-wins/${it.id}')),
                            )
                            .toList(),
                      ),
                    )
                  ],
                );
              }),
          const AppTabBar(currentIndex: 2),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String text,
    Widget subtitle,
    String imageUrl, {
    EdgeInsetsGeometry margin,
    BorderRadius borderRadius,
    void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.white,
              ),
              margin: margin,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 45.0,
                        width: 45.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(imageUrl),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            style: TextStyle(
                                color: CupertinoTheme.of(context).primaryColor),
                          ),
                          subtitle,
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    CupertinoIcons.right_chevron,
                    size: 35.0,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Divider(
                  height: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashSalesCount(BuildContext context) {
    return StreamBuilder<Map<String, List<Flashsale>>>(
      stream: FlashsellsProvider.of(context).flashsells,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '[my_wins_screen] Could not fetch flash sales. Error: ${snapshot.error}');

          return Text('...');
        }

        if (!snapshot.hasData) {
          return Text('...');
        }

        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '${snapshot.data['loc'].length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              TextSpan(
                text: ' items',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponsCount(BuildContext context) {
    return StreamBuilder<List<Coupon>>(
      stream: MyWinsBlocProvider.of(context).coupons,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '[my_wins_screen] Could not fetch coupons. Error: ${snapshot.error}');

          return Text('...');
        }

        if (!snapshot.hasData) {
          return Text('...');
        }

        if (snapshot.data.length == 0) {
          return Text(
            'No coupon available',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          );
        }

        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '${snapshot.data.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              TextSpan(
                text: ' items',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVouchersCount(BuildContext context) {
    return StreamBuilder<List<Voucher>>(
      stream: MyWinsBlocProvider.of(context).vouchers,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '[my_wins_screen] Could not fetch vouchers. Error: ${snapshot.error}');

          return Text('...');
        }

        if (!snapshot.hasData) {
          return Text('...');
        }

        if (snapshot.data.length == 0) {
          return Text(
            'No voucher available',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          );
        }

        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'Rs ',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
              TextSpan(
                text:
                    '${snapshot.data.fold<int>(0, (acc, v) => acc + v.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftVouchersCount(BuildContext context) {
    return StreamBuilder<List<GiftVoucher>>(
      stream: MyWinsBlocProvider.of(context).giftVoucher,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '[my_wins_screen] Could not fetch gift vouchers. Error: ${snapshot.error}');

          return Text('...');
        }

        if (!snapshot.hasData) {
          return Text('...');
        }

        if (snapshot.data.length == 0) {
          return Text(
            'No gift voucher available',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          );
        }

        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'Rs ',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
              ),
              TextSpan(
                text:
                    '${_formatter.format(snapshot.data.fold<int>(0, (acc, v) => acc + v.amount))}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCount(BuildContext context, String id) {
    switch (id) {
      case 'flashsale':
        return _buildFlashSalesCount(context);
      case 'coupons':
        return _buildCouponsCount(context);
      case 'vouchers':
        return _buildVouchersCount(context);
      case 'gift-vouchers':
        return _buildGiftVouchersCount(context);
      default:
        return Container();
    }
  }
}
