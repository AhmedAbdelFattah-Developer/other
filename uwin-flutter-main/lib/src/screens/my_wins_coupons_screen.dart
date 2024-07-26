import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/models/coupon.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';
import '../blocs/providers/my_wins_bloc_provider.dart';

class MyWinsCouponsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Coupons'),
            trailing: ScanPartnerQrButton(),
          ),
          _buildCoupons(context),
        ],
      ),
    );
  }

  Widget _buildStreamError(err) {
    return SliverFillRemaining(
      child: Center(
        child: Text('$err'),
      ),
    );
  }

  final Widget activityIndicator = const SliverFillRemaining(
    child: Center(
      child: CupertinoActivityIndicator(),
    ),
  );

  Widget _buildCoupons(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 400).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 314;
    final tileAspectRatio = tileWidth / tileHeight;
    final bloc = MyWinsBlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.coupons,
      builder: (BuildContext context, AsyncSnapshot<List<Coupon>> snapshot) {
        if (snapshot.hasError) {
          return _buildStreamError(snapshot.error);
        }

        if (!snapshot.hasData) {
          return activityIndicator;
        }

        if (snapshot.data.length == 0) {
          return _buildStreamError('No coupon available');
        }

        return SliverPadding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            bottom: 70.0,
            right: 20.0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400.0,
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: tileAspectRatio,
            ),
            delegate: SliverChildListDelegate(
              snapshot.data.map((Coupon coupon) {
                return _CouponGridItem(coupon);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CouponGridItem extends StatelessWidget {
  final Coupon coupon;

  _CouponGridItem(this.coupon);

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/shops/show',
        arguments: <String, dynamic>{'id': coupon.shopId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x3C000000),
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(coupon.photoPath != ''
                      ? 'https://u-win.shop/files/shops/${coupon.shopId}/${coupon.photoPath}'
                      : 'https://u-win.shop/files/shops/${coupon.shopId}/${coupon.itemPhotoPath}'),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    coupon.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    coupon.itemName,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(3.0),
                            ),
                            border: Border.all(
                              color: primaryColor,
                            )),
                        child: Text(
                          coupon.shopName,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(3.0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 10.0,
                        ),
                        child: Text(
                          '-${coupon.discountValue}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${coupon.itemPrice}',
                        style: TextStyle(
                          fontSize: 12.0,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        '${coupon.itemDiscountedPrice}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
