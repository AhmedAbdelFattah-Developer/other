import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uwin_flutter/src/blocs/shop_bloc.dart';
import 'package:uwin_flutter/src/models/pos.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/screens/buy_gift_vouchers_screen.dart';
import 'package:uwin_flutter/src/screens/sport_shop_screen.dart';
import 'package:uwin_flutter/src/widgets/GmsAvailable.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';

_launchPhone(String phone) async {
  final url = 'tel:${phone.replaceAll(' ', '-')}';

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget _buildTitle(text) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
    child: Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

class ShopScreen extends StatelessWidget {
  static const double padding = 20.0;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ShopBloc>(context, listen: false);

    const Border border = Border(
      top: BorderSide(
        color: Color(0x4C000000),
        width: 0.0, // One physical pixel.
        style: BorderStyle.solid,
      ),
    );

    return StreamBuilder(
      stream: bloc.shopWithPos,
      builder: (BuildContext context, AsyncSnapshot<Shop> snapshot) {
        if (!snapshot.hasData) {
          return CupertinoPageScaffold(
            backgroundColor: Color(0xFFEFEFEF),
            child: Container(
              child: CupertinoActivityIndicator(),
              alignment: Alignment.center,
            ),
          );
        }

        if (snapshot.hasError) {
          return CupertinoPageScaffold(
            backgroundColor: Color(0xFFEFEFEF),
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.data.shopTypeId == '6246ac52263c7950c2a11001' ||
            snapshot.data.id == '66794d56e9c6ae6e441d30d7') {
          return SportShopScreen(shop: snapshot.data);
        }

        return CupertinoPageScaffold(
          backgroundColor: Color(0xFFEFEFEF),
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: false,
            middle: Text(snapshot.data.name),
            trailing: ScanPartnerQrButton(),
          ),
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: _ShopScreenContent(snapshot.data, snapshot.data.name),
              ),
              StreamBuilder<bool>(
                stream: bloc.haveBottomBar,
                builder: (context, snapshotAccess) {
                  if (snapshotAccess.hasError ||
                      !snapshotAccess.hasData ||
                      snapshotAccess.hasData && !snapshotAccess.data) {
                    return Container();
                  }

                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, border: border),
                      height: 90.0,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: padding,
                          ),
                          child: _buildButtons(context, snapshot.data)
                          // child: ;
                          //   },
                          // ),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context, Shop sh) {
    return StreamBuilder<Map<String, bool>>(
      stream: Provider.of<ShopBloc>(context, listen: false).buttons,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('[shop_screen] ${snapshot.error}');

          return Container(child: Text('Unable to load buttons'));
        }

        if (!snapshot.hasData) {
          return Container();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (snapshot.data['canBuyOnline'])
              _buildBuyOnlineButton(context, sh),
            if (snapshot.data['buyGiftVouchers'])
              _buildBuyGiftVouchersButton(context),
            if (snapshot.data['hasCatalog']) _buildCatalogButton(context, sh),
            if (snapshot.data['canSellVoucher']) _buildBuyVoucher(context, sh),
            if (snapshot.data['canBuyNow']) _buildBuyNowButton(context, sh),
          ],
        );
      },
    );
  }

  Widget _buildBuyNowButton(BuildContext context, Shop sh) {
    return CupertinoButton(
      padding: EdgeInsets.all(12.0),
      color: Color(0xFFFE9B2C),
      child: Text(
        'BUY NOW',
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(
          '/shops/checkout',
          arguments: <String, dynamic>{
            'shopId': sh.id,
          },
        );
      },
    );
  }

  Widget _buildCatalogButton(BuildContext context, Shop sh) {
    return CupertinoButton(
      padding: EdgeInsets.all(12.0),
      color: Color(0xFFFE9B2C),
      child: Text(
        'VIEW CATALOGUE',
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      onPressed: () => Navigator.of(context).pushNamed(
        '/shops/catalog',
        arguments: {'shop': sh},
      ),
    );
  }

  Widget _buildBuyOnlineButton(BuildContext context, Shop shop) {
    return CupertinoButton(
      padding: EdgeInsets.all(12.0),
      color: Color(0xFFFE9B2C),
      child: Text(
        'ONLINE STORE',
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      onPressed: () async {
        try {
          await _launchURL(shop.websiteSafeUrl);
        } catch (err) {
          print('[shop_screen] Could not open online store.');
          print(err);

          showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text('Online Store Error',
                    style: TextStyle(
                        color: CupertinoTheme.of(context).primaryColor)),
                message: Text(
                  'Unable to open URL: ${shop.websiteSafeUrl}',
                  style: TextStyle(color: Colors.black87),
                ),
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildBuyVoucher(BuildContext context, Shop sh) {
    return CupertinoButton(
      padding: EdgeInsets.all(12.0),
      color: Color(0xFFFE9B2C),
      child: Text(
        'BUY VOUCHER',
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(
          '/shops/vouchers',
          arguments: <String, dynamic>{
            'shop': sh,
          },
        );
      },
    );
  }

  Widget _buildBuyGiftVouchersButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.all(12.0),
      color: Color(0xFFFE9B2C),
      child: Text(
        'BUY GIFT VOUCHERS',
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(
          BuyGiftVoucherScreen.route,
        );
      },
    );
  }
}

class _ShopScreenContent extends StatelessWidget {
  static const double padding = 20.0;
  final String title;
  final Shop shop;

  _ShopScreenContent(this.shop, this.title);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ShopBloc>(context, listen: false);

    return StreamBuilder<bool>(
      stream: bloc.canAccess,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              '[_ShopScreenContent.build] Could not check if shop is for adult only.');

          return Center(child: Text('An unexpected error has occured.'));
        }

        if (!snapshot.hasData) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }

        final canAccess = snapshot.data;

        return CustomScrollView(
          slivers: <Widget>[
            if (!canAccess)
              SliverToBoxAdapter(
                child: _AdultAccessRestrictedMsg(),
              ),
            if (canAccess)
              SliverToBoxAdapter(
                child: _buildHeadImage(),
              ),
            if (canAccess)
              SliverToBoxAdapter(
                child: _buildHeading(context),
              ),
            if (canAccess)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    shop.shopTypeName,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
            if (canAccess)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    shop.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                ),
              ),
            if (canAccess && shop.posList.length > 0)
              SliverToBoxAdapter(
                child: GmsAvailable(
                  child: Container(
                    child: _buildTitle('Location'),
                    margin: EdgeInsets.only(bottom: 20.0),
                  ),
                ),
              ),
            if (canAccess && shop.posList.length > 0)
              SliverToBoxAdapter(
                child: GmsAvailable(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: _buildMap(context),
                  ),
                ),
              ),
            if (canAccess && shop.posList.length > 0)
              SliverToBoxAdapter(
                child: Container(
                  child: _buildTitle('Shops'),
                  margin: EdgeInsets.only(bottom: 20.0),
                ),
              ),
            if (canAccess && shop.posList.length > 0)
              _buildPosList(
                context,
              ),
            SliverToBoxAdapter(
              child: StreamBuilder<bool>(
                  stream: bloc.haveBottomBar,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data) {
                      return Container();
                    }

                    return SizedBox(
                      height: 90.0,
                    );
                  }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPosList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 200).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 246;
    final tileAspectRatio = tileWidth / tileHeight;

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 10.0,
        right: 10.0,
        bottom: 100.0,
        left: 10.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 30.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: tileAspectRatio,
        ),
        delegate: SliverChildListDelegate(
          shop.posList.map((Pos pos) => _PosTile(shop, pos)).toList(),
        ),
      ),
    );
  }

  Widget _buildHeadImage() {
    final bannerUrl = shop.bannerUrl;

    return bannerUrl == null
        ? Container()
        : Container(
            height: 250.0,
            margin: EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              image: new DecorationImage(
                image: NetworkImage(
                  'https://u-win.shop/files/shops/${shop.id}/$bannerUrl',
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  Widget _buildHeading(BuildContext context) {
    final bloc = Provider.of<ShopBloc>(context, listen: false);
    final image = shop.logoUrl;
    final favLabelStyle = TextStyle(
      color: CupertinoTheme.of(context).primaryColor,
      fontSize: 10.0,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          image == null
              ? Container()
              : Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: new DecorationImage(
                      image: NetworkImage(
                        'https://u-win.shop/files/shops/${shop.id}/$image',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          StreamBuilder<String>(
            stream: bloc.favorite,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return Container(
                  child: Text('...'),
                );
              }

              switch (snapshot.data) {
                case 'on':
                  return GestureDetector(
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.heart_solid, size: 30.0),
                          Text('Remove from favourite', style: favLabelStyle),
                        ],
                      ),
                      onTap: () {
                        bloc.setFavorite(shop.id, false);
                      });
                case 'off':
                  return GestureDetector(
                      child: Column(
                        children: [
                          Icon(CupertinoIcons.heart, size: 30.0),
                          Text('Add to favourite', style: favLabelStyle),
                        ],
                      ),
                      onTap: () {
                        bloc.setFavorite(shop.id, true);
                      });
                default:
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      child: MarkerIconsBody(shop.posList),
    );
  }
}

class MarkerIconsBody extends StatefulWidget {
  final List<Pos> posList;
  final LatLng _kMapCenter;

  MarkerIconsBody(this.posList)
      : _kMapCenter = LatLng(posList.first.lat, posList.first.lng);

  @override
  State<StatefulWidget> createState() => MarkerIconsBodyState();
}

class MarkerIconsBodyState extends State<MarkerIconsBody> {
  GoogleMapController controller;
  BitmapDescriptor _markerIcon;

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget._kMapCenter,
        zoom: widget.posList.length > 1 ? 9.0 : 16,
      ),
      mapType: MapType.hybrid,
      markers: _createMarker(),
      onMapCreated: _onMapCreated,
    );
  }

  Set<Marker> _createMarker() {
    return widget.posList
        .map<Marker>((Pos pos) {
          return Marker(
            markerId: MarkerId(pos.id),
            position: LatLng(pos.lat, pos.lng),
            // icon: _markerIcon,
          );
        })
        .toList()
        .toSet();
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/red_square.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }
}

class _PosTile extends StatelessWidget {
  final Shop shop;
  final Pos pos;

  _PosTile(this.shop, this.pos);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/pos/show',
          arguments: <String, dynamic>{
            'shopId': pos.shop.id,
            'posId': pos.id,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5.0),
                ),
                image: pos.photoPath.length > 0
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://u-win.shop/files/shops/${shop.id}/${pos.photoPath.first}',
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pos.name,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    pos.cityName,
                    style: const TextStyle(fontSize: 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    pos.address,
                    style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () => _launchPhone(pos.tel),
                    child: Text(
                      'Call: ${pos.tel}',
                      style: const TextStyle(
                        color: Color(0xFFFE9015),
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _AdultAccessRestrictedMsg extends StatefulWidget {
  @override
  __AdultAccessRestrictedMsgState createState() =>
      __AdultAccessRestrictedMsgState();
}

class __AdultAccessRestrictedMsgState extends State<_AdultAccessRestrictedMsg> {
  final idCardTextCtrl = TextEditingController();

  Widget build(BuildContext context) {
    final bloc = Provider.of<ShopBloc>(context, listen: false);

    return Material(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
                title: Text(
              'Access Denied',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'This shop is restricted to members over 18 only. Please enter you National ID card number to have access to this shop.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'NATIONAL ID CARD NUMBER',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoTextField(
                    controller: idCardTextCtrl,
                    onChanged: bloc.changeIdCardNumber,
                  ),
                  StreamBuilder<bool>(
                      stream: bloc.idCardNumberValid,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && !snapshot.data) {
                          return Text(
                            'Invalid format',
                            style: TextStyle(fontSize: 12.0, color: Colors.red),
                          );
                        } else {
                          return Container();
                        }
                      }),
                  SizedBox(height: 8),
                  StreamBuilder<ButtonState>(
                    stream: bloc.idCardNumberFormButtonState,
                    builder: (context, snapshot) {
                      return CupertinoButton(
                        onPressed: snapshot.hasData &&
                                snapshot.data == ButtonStates.enabled
                            ? () {
                                bloc.saveIdCardNumber();
                              }
                            : null,
                        color: CupertinoTheme.of(context).primaryColor,
                        disabledColor: CupertinoTheme.of(context)
                            .primaryColor
                            .withAlpha(100),
                        child: snapshot.hasData &&
                                snapshot.data == ButtonStates.spinning
                            ? CupertinoActivityIndicator()
                            : Text('Save'),
                      );
                    },
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
