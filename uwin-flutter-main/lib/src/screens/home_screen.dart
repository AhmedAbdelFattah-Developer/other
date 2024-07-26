import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/home_bloc.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/dialogs/show_gift_voucher_dialog.dart';
import 'package:uwin_flutter/src/dialogs/show_voucher_dialog.dart';
import 'package:uwin_flutter/src/formatters/currency_formatter.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/models/shop_type.dart';
import 'package:uwin_flutter/src/screens/how_to_use_screen.dart';
import 'package:uwin_flutter/src/widgets/ticket_card.dart';

import '../blocs/providers/coupons_bloc_provider.dart';
import '../blocs/providers/flashsells_bloc_provider.dart';
import '../blocs/providers/my_wins_bloc_provider.dart';
import '../models/coupon.dart';
import '../models/flashsale.dart';
import '../models/voucher.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/pos_tile.dart';
import '../widgets/scan_partner_qr_partner.dart';
import '../models/banner.dart' as models;

final _formatter = CurrencyFormatter(decimalDigits: 0);

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  final FlashsellsBloc bloc;
  final CouponsBloc couponsBloc;
  final MyWinsBloc myWinsBloc;

  HomeScreen(this.bloc, this.couponsBloc, this.myWinsBloc);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    widget.bloc.fetch();
    widget.bloc.fetchPosList();
    widget.couponsBloc.fetch();
    widget.myWinsBloc.fetchVoucher();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;

    final screen = CupertinoPageScaffold(
      //backgroundColor: const Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: CupertinoButton(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF59C4B8),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'How to use?',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context).pushNamed(HowToUseScreen.routeName);
            }),
        middle: const Text('uWin'),
        trailing: ScanPartnerQrButton(),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: StreamBuilder<Map<String, List<Flashsale>>>(
              stream: bloc.flashsells,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, List<Flashsale>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }

                return _HomeContent(snapshot.data);
              },
            ),
          ),
          const AppTabBar(currentIndex: 0),
        ],
      ),
    );

    return screen;
  }
}

class _HomeContent extends StatelessWidget {
  final Map<String, List<Flashsale>> flashsaleGroup;

  _HomeContent(this.flashsaleGroup, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacer = const SliverToBoxAdapter(child: SizedBox(height: 8.0));
    final header = <Widget>[
      SliverToBoxAdapter(child: _buildHomeBanner(context)),
      spacer,
      SliverToBoxAdapter(child: UnlockVouchersNotice()),
      SliverToBoxAdapter(child: _buildCategoryTitle(context)),
      SliverToBoxAdapter(child: _CategoryRowList()),
      SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];

    return NestedScrollView(
      headerSliverBuilder: (context, _) => header,
      body: _TabbedContent(),
    );
  }

  Widget _buildCategoryTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/find-shops/by-category',
                  arguments: <String, dynamic>{'category': ''},
                );
              },
              icon: Icon(
                CupertinoIcons.search,
                size: 40.0,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTiles(BuildContext context) {
    return StreamBuilder<List<ShopType>>(
      stream: Provider.of<HomeBloc>(context, listen: false).shopTypeList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        return UniverseList(list: snapshot.data);
      },
    );
  }

  Widget _buildShopList(BuildContext context) {
    final bloc = FlashsellsProvider.of(context);

    return StreamBuilder<List<Shop>>(
      stream: bloc.shopList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoActivityIndicator(),
          );
        }

        return _ShopResult(snapshot.data);
      },
    );
  }

  Widget _buildHomeBanner(BuildContext context) {
    return StreamBuilder<models.Banner>(
      stream: FlashsellsProvider.of(context).homeBanner,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Home Banner Error: ${snapshot.error}');
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data.published == false) {
          return Container();
        }

        return GestureDetector(
          onTap: () {
            // final uri = '/find-shops/by-category?category=Food%20%26%20Drinks';
            final uri = snapshot.data.uri;
            if (uri == null || uri.trim().isEmpty) {
              return;
            }

            final nodes = uri.split('?');
            final routeName = nodes.first;

            final arguments = nodes.length > 1
                ? Map<String, dynamic>.fromEntries(
                    nodes[1].split('&').map<MapEntry<String, dynamic>>(
                      (e) {
                        final splitted = e.split('=');

                        return MapEntry<String, dynamic>(
                            splitted[0], Uri.decodeComponent(splitted[1]));
                      },
                    ),
                  )
                : null;
            Navigator.of(context).pushNamed(routeName, arguments: arguments);
          },
          child: Image.network(
            snapshot.data.downloadUrl,
            fit: BoxFit.fitWidth,
          ),
        );
      },
    );
  }
}

Widget _buildTitle(text) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildSubtitle(text) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF757575),
      ),
    ),
  );
}

class _Coupons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = CouponsBlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.coupons,
      builder: (BuildContext context, AsyncSnapshot<List<Coupon>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              // child: CupertinoActivityIndicator(),
              );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.data.length == 0) {
          return Container();
        }

        return _NotifyBox(
          icon: Icon(
            Icons.star_border,
            size: 20.0,
            color: Colors.white,
          ),
          title: 'Coupons',
          onPress: () => Navigator.of(context).pushReplacementNamed(
            '/my-wins',
            arguments: <String, dynamic>{'tab': 'my_coupons'},
          ),
          message:
              'You have ${snapshot.data.length} coupon${snapshot.data.length > 1 ? "s" : ""} available',
        );
      },
    );
  }
}

class _Vouchers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = MyWinsBlocProvider.of(context);

    return StreamBuilder<List<Voucher>>(
      stream: bloc.vouchers,
      builder: (BuildContext context, AsyncSnapshot<List<Voucher>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            child: _NotifyBox(
              icon: Icon(
                Icons.redeem,
                size: 20.0,
                color: Colors.white,
              ),
              title: 'Vouchers',
              message: 'Loading...',
            ),
          );
        }

        if (snapshot.data.length == 0) {
          return Container();
        }

        return _NotifyBox(
          icon: Icon(
            Icons.redeem,
            size: 20.0,
            color: Colors.white,
          ),
          title: 'Vouchers',
          onPress: () => Navigator.of(context).pushReplacementNamed(
            '/my-wins',
            arguments: <String, dynamic>{'tab': 'my_voucher'},
          ),
          message:
              'You have ${_formatter.format(snapshot.data.fold<int>(0, (acc, cur) => acc + cur.amount) * 100)} vouchers available',
        );
      },
    );
  }
}

class _NotifyBox extends StatelessWidget {
  final Function onPress;
  final String message;
  final Icon icon;
  final String title;

  _NotifyBox({
    @required this.title,
    this.onPress,
    this.message,
    this.icon,
  });

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 5.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: onPress,
                child: Row(
                  children: [
                    if (icon != null)
                      GestureDetector(
                        onTap: onPress,
                        child: icon,
                      ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text(
                        //   title,
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        // SizedBox(height: 3.0),
                        if (message != null)
                          Text(
                            message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // GestureDetector(
              //   onTap: () =>
              //       Navigator.of(context).pushNamed(HowToUseScreen.routeName),
              //   child: Container(
              //     width: 70.0,
              //     height: 70.0,
              //     alignment: Alignment.center,
              //     decoration: const BoxDecoration(
              //       image: DecorationImage(
              //         image: AssetImage('assets/icon_golden.png'),
              //         fit: BoxFit.scaleDown,
              //       ),
              //     ),
              //     child: const Text(
              //       'How\nto use',
              //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopResult extends StatelessWidget {
  final List<Shop> shopList;

  _ShopResult(this.shopList);

  @override
  Widget build(BuildContext context) {
    if (shopList.length == 0) {
      return Center(
        child: Text('No shop found.'),
      );
    }

    final children = shopList
        .map(
          (shop) => Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShopTile(shop),
            ),
          ),
        )
        .toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: children,
    );
  }
}

class UniverseList extends StatelessWidget {
  final List<ShopType> list;
  // static const size = 150.0;
  // static const assets = [
  //   'assets/universe/category_fashion.png',
  //   'assets/universe/category_restaurant.png',
  //   'assets/universe/category_health.png',
  //   'assets/universe/category_kids_teens.png',
  //   'assets/universe/category_entertainment.png',
  //   'assets/universe/category_technologies.png',
  //   'assets/universe/category_home_garden.png',
  //   'assets/universe/category_art.png',
  //   'assets/universe/category_groceries.png',
  // ];
  // static const assetLinks = <String, String>{
  //   'assets/universe/category_art.png': 'Arts & Culture',
  //   'assets/universe/category_entertainment.png': 'Leisure & Entertainment',
  //   'assets/universe/category_fashion.png': 'Fashion',
  //   'assets/universe/category_kids_teens.png': 'Kids & Teens',
  //   'assets/universe/category_technologies.png': 'Mobile & Electronics',
  //   'assets/universe/category_groceries.png': 'Supermarkets',
  //   'assets/universe/category_health.png': 'Health & Beauty',
  //   'assets/universe/category_home_garden.png': 'Home & Garden',
  //   'assets/universe/category_restaurant.png': 'Food & Drinks',
  // };
  final Widget divider = SizedBox(width: 8.0);

  UniverseList({Key key, @required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final shopType in list) {
      children.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/find-shops/by-category',
              arguments: <String, dynamic>{
                'category': shopType.name,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(shopType.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: StreamBuilder<Map<String, num>>(
                    stream: Provider.of<HomeBloc>(
                      context,
                      listen: false,
                    ).voucherPerCategory,
                    builder: (context, snapshot) {
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (snapshot.hasData &&
                                snapshot.data[shopType.id] != null &&
                                snapshot.data[shopType.id] > 0)
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                child: Text(
                                  'Rs ${snapshot.data[shopType.id].round()} Vouchers',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                            SizedBox(height: 6.0),
                            Text(
                              shopType.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      physics: ScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      children: children,
      childAspectRatio: 0.8,
    );
  }
}

class UnlockVouchersNotice extends StatelessWidget {
  static const msg = 'Complete your profile to unlock all vouchers';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: AuthBlocProvider.of(context).authState,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('${snapshot.error}');

            return Container();
          }

          if (!snapshot.hasData) {
            return Container();
          }

          if (snapshot.data == 'completed') {
            return Container();
          }

          return _NotifyBox(
            title: 'asdf',
            icon: Icon(
              Icons.lock,
              size: 20.0,
              color: Colors.white,
            ),
            message: msg,
          );
        });
  }
}

class _CategoryRowList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: StreamBuilder<List<ShopType>>(
        stream: Provider.of<HomeBloc>(context, listen: false).shopTypeList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/find-shops/by-category',
                      arguments: <String, dynamic>{
                        'category': snapshot.data[index].name,
                      },
                    );
                  },
                  child: _ShopTypeCard(shopType: snapshot.data[index]));
            },
          );
        },
      ),
    );
  }
}

class _ShopTypeCard extends StatelessWidget {
  final ShopType shopType;

  const _ShopTypeCard({Key key, this.shopType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 5.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: Column(
            children: [
              Container(
                height: 125.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.black,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(shopType.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  shopType.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          width: 150.0,
        ));
  }
}

class _VoucherList extends StatelessWidget {
  @override
  Widget build(context) {
    return StreamBuilder<List<Voucher>>(
        stream: MyWinsBlocProvider.of(context).vouchers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          final widgets = <Widget>[];
          for (int i = 0; i < snapshot.data.length; i++) {
            widgets.add(
              TicketCard(
                imageUrl:
                    'https://u-win.shop/files/shops/${snapshot.data[i].shopId}/${snapshot.data[i].photoPath}',
                title: snapshot.data[i].shopName,
                amount: '${snapshot.data[i].amount}',
                onPress: () => showVoucherDialog(context, snapshot.data[i]),
                stripped: i % 2 == 0,
                colors: i % 2 == 0
                    ? [
                        Color(0xFFE27F34),
                        Color(0xFFF59547),
                      ]
                    : [
                        Color(0xFF4092CA),
                        Color(0xFF50A7DF),
                      ],
              ),
            );
          }

          return ListView(
            children: widgets,
            shrinkWrap: true,
          );
        });
  }
}

class _GiftVoucherList extends StatelessWidget {
  @override
  Widget build(context) {
    return StreamBuilder<List<GiftVoucher>>(
        stream: MyWinsBlocProvider.of(context).giftVoucher,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          if (snapshot.data.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No gift voucher',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navLargeTitleTextStyle,
                  ),
                  Text(
                    'Participate in surveys, increase number of points and exchange them for gift vouchers.',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                    child: Text('Win Vouchers'),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed('/win-credits'),
                  ),
                ],
              ),
            );
          }

          final widgets = <Widget>[];
          for (int i = 0; i < snapshot.data.length; i++) {
            widgets.add(
              TicketCard(
                onPress: () => showGiftVoucherDialog(
                  context,
                  snapshot.data[i],
                ),
                imageUrl:
                    'https://u-win.shop/files/shops/${snapshot.data[i].shopId}/${snapshot.data[i].photoPath}',
                title: snapshot.data[i].shopName,
                amount: '${(snapshot.data[i].amount / 100).round()}',
                colors: i % 2 == 0
                    ? [
                        Color(0xFFE27F34),
                        Color(0xFFF59547),
                      ]
                    : [
                        Color(0xFF4092CA),
                        Color(0xFF50A7DF),
                      ],
              ),
            );
          }

          return ListView(
            children: widgets,
            shrinkWrap: true,
          );
        });
  }
}

class _TabbedContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      Tab(text: 'Voucher'),
      Tab(text: 'Gift Vouchers'),
      Tab(text: 'Coupon'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBar(
          labelColor: CupertinoTheme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicator: DotTabIndicator(
            color: CupertinoTheme.of(context).primaryColor,
            radius: 3.0,
          ),
          tabs: tabs,
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _VoucherList(),
                  _GiftVoucherList(),
                  Center(child: Text('No coupon available')),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class DotTabIndicator extends Decoration {
  final double radius;
  final Color color;

  DotTabIndicator({@required this.radius, @required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _DotPainter(radius: radius, color: color);
  }
}

class _DotPainter extends BoxPainter {
  final double radius;
  final Color color;

  _DotPainter({@required this.radius, @required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()..color = color;
    final center = Offset(
      offset.dx + configuration.size.width / 2,
      offset.dy + configuration.size.height - radius,
    );
    canvas.drawCircle(center, radius, paint);
  }
}
