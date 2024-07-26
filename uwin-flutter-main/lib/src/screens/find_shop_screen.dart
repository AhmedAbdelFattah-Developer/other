import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uwin_flutter/src/blocs/providers/pos_query_bloc_provider.dart';
import 'package:uwin_flutter/src/dialogs/show_voucher_dialog.dart';
import 'package:uwin_flutter/src/models/pos.dart';
import 'package:uwin_flutter/src/models/shop_type.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/widgets/app_tab_bar.dart';
import 'package:uwin_flutter/src/widgets/pos_tile.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';

const double _tabItemWidth = 100.0;

class FindShopScreen extends StatefulWidget {
  final String category;
  final String query;
  final PosQueryBloc queryBloc;
  final bool autofocus;

  FindShopScreen(
    this.queryBloc,
    this.category, {
    this.query = '',
    this.autofocus = false,
  });

  @override
  _FindShopScreenState createState() => _FindShopScreenState();
}

class _FindShopScreenState extends State<FindShopScreen> {
  // final _textEditingCtrl = TextEditingController();

  @override
  void initState() {
    widget.queryBloc.fetch(widget.category, query: widget.query);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = PosQueryBlocProvider.of(context);

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      child: Stack(
        children: <Widget>[
          SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    ScanPartnerQrButton(),
                  ],
                  title: Text(
                    'Discover partners & products',
                    style: TextStyle(
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                      fontSize: 18.0,
                    ),
                  ),
                  floating: true,
                  backgroundColor: CupertinoTheme.of(context)
                      .barBackgroundColor
                      .withAlpha(255),
                  pinned: true,
                  expandedHeight: 193,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: <Widget>[
                        SizedBox(height: 50.0),
                        _SearchForm(
                          widget.category,
                          widget.query,
                          autofocus: widget.autofocus,
                        ),
                        Container(
                          height: 85.0,
                          decoration: BoxDecoration(
                            border: const Border(
                              bottom: BorderSide(
                                color: const Color(0x4C000000),
                                width: 0.0, // One physical pixel.
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: _buildShopTabs(context),
                        )
                      ],
                    ),
                  ),
                ),
                _buildVoucherSection(context),
                StreamBuilder<List<Pos>>(
                  stream: bloc.posList,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(top: 50.0),
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    }

                    return _PosResult(snapshot.data);
                  },
                ),
                SliverToBoxAdapter(child: SizedBox(height: 40.0)),
              ],
            ),
          ),
          const AppTabBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget buildTitle(text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildSubtitle(text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _buildVoucherSection(BuildContext context) {
    final bloc = PosQueryBlocProvider.of(context);

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: StreamBuilder<List<Voucher>>(
          stream: bloc.voucherList,
          builder: (context, snapshot) {
            const height = 160.0;

            if (snapshot.hasError) {
              return Container(
                height: height,
                child: Center(child: Text('${snapshot.error}')),
              );
            }

            if (!snapshot.hasData) {
              return Container(
                height: height,
                child: Center(child: CupertinoActivityIndicator()),
              );
            }

            if (snapshot.data.isEmpty) {
              return Container();
            }

            return Container(
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      left: 8,
                      right: 8,
                    ),
                    child: Text('Vouchers'),
                  ),
                  Expanded(child: _VoucherSection(snapshot.data)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ScrollController _tabsScrollCtrl = ScrollController();

  _buildShopTabs(BuildContext context) {
    final bloc = PosQueryBlocProvider.of(context);

    return StreamBuilder<List<ShopType>>(
      stream: bloc.shopTypeList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FindShopTabs(
            category: widget.category,
            tabsContent: [],
            offset: 0,
            tabsScrollCtrl: _tabsScrollCtrl,
          );
        }

        if (!snapshot.hasData) {
          return FindShopTabs(
            category: widget.category,
            tabsContent: [],
            offset: 0,
            tabsScrollCtrl: _tabsScrollCtrl,
          );
        }

        final tabsContent = initTabContent(snapshot.data);
        final list = tabsContent.map<String>((Map<String, String> content) {
          return content['query'];
        }).toList();
        final offset = list.indexOf(widget.category) * _tabItemWidth;
        _tabsScrollCtrl.jumpTo(offset);

        return FindShopTabs(
          category: widget.category,
          tabsContent: tabsContent,
          offset: offset,
          tabsScrollCtrl: _tabsScrollCtrl,
        );
      },
    );
  }
}

class _PosResult extends StatelessWidget {
  final List<Pos> posList;

  _PosResult(this.posList);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 200).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 255;
    final tileAspectRatio = tileWidth / tileHeight;

    if (posList.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text('No shop found.'),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(20.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: tileAspectRatio,
        ),
        delegate: SliverChildListDelegate(posList
            .map((Pos pos) => PosTile(
                  pos,
                  name: pos.shop.name,
                ))
            .toList()),
      ),
    );
  }
}

class _SearchForm extends StatefulWidget {
  final String category;
  final String query;
  final bool enabled;
  final bool autofocus;

  _SearchForm(
    this.category,
    this.query, {
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  __SearchFormState createState() => __SearchFormState();
}

class __SearchFormState extends State<_SearchForm> {
  final _textEditingCtrl = TextEditingController();

  @override
  void initState() {
    _textEditingCtrl.text = widget.query;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = PosQueryBlocProvider.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 16.0),
      child: Container(
        height: 36.0,
        width: double.infinity,
        child: CupertinoTextField(
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          onChanged: (val) => bloc.changeQuery(widget.category, val),
          onTap: () => Navigator.of(context).pushReplacementNamed(
            '/find-shops/by-category/query',
            arguments: <String, dynamic>{'category': '', 'autofocus': true},
          ),
          // onSubmitted: (val) => Navigator.of(context).pushReplacementNamed(
          //   '/find-shops/by-category/query',
          //   arguments: <String, dynamic>{
          //     'category': '',
          //     'query': val,
          //   },
          // ),
          controller: _textEditingCtrl,
          keyboardType: TextInputType.text,
          placeholder: 'Search',
          placeholderStyle: TextStyle(
            color: Colors.black45,
            fontSize: 14.0,
          ),
          prefix: Padding(
            padding: const EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
            child: Icon(
              Icons.search,
              color: Colors.black45,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Color(0xffF0F1F5),
          ),
        ),
      ),
    );
  }
}

class _VoucherSection extends StatelessWidget {
  final List<Voucher> list;

  const _VoucherSection(this.list);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => _VoucherItem(list[index]),
      itemCount: list.length,
    );
  }
}

final formatter = new NumberFormat("#,##0.00", "en_US");

class _VoucherItem extends StatelessWidget {
  final Voucher voucher;

  const _VoucherItem(this.voucher);

  @override
  Widget build(BuildContext context) {
    final imgSrc = 'https://u-win.shop/files/shops' +
        '/${voucher.shopId}/${voucher.photoPath}';
    return GestureDetector(
      onTap: () => showVoucherDialog(context, voucher),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: const Color(0xFF59C4B8),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: 70.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: new DecorationImage(
                    image: NetworkImage(imgSrc),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Container(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF59C4B8),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                child: Text(
                  'Rs ${formatter.format(voucher.amount)}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
class FindShopTabs extends StatefulWidget {
  final String category;
  final List<Map<String, String>> tabsContent;
  final double offset;
  final ScrollController tabsScrollCtrl;

  FindShopTabs({
    Key key,
    @required this.category,
    @required this.tabsContent,
    @required this.offset,
    @required this.tabsScrollCtrl,
  }) : super(key: key);

  @override
  State<FindShopTabs> createState() => _FindShopTabsState();
}

class _FindShopTabsState extends State<FindShopTabs> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.tabsScrollCtrl,
      scrollDirection: Axis.horizontal,
      children: widget.tabsContent
          .map<Widget>((Map<String, String> content) => _buildTabItem(
                context,
                content['title'],
                content['asset'],
                query: content['query'],
                active: content['query'] == widget.category,
              ))
          .toList(),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, String asset,
      {String query, bool active = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed(
        '/find-shops/by-category',
        arguments: <String, dynamic>{'category': query ?? title},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        width: _tabItemWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(asset),
          ),
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(2.0),
            color: Colors.white.withAlpha(225),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: active
                    ? CupertinoTheme.of(context).primaryColor
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, String>> initTabContent(List<ShopType> shopTypes) {
  final shopTypesMap = List<Map<String, String>>.from(
    shopTypes.map(
      (e) => <String, String>{
        'title': e.name,
        'query': e.name,
        'asset': e.iconUrl,
      },
    ),
  );

  return <Map<String, String>>[
    {
      'title': 'Favourite',
      'query': 'Favourite',
      'asset':
          'https://firebasestorage.googleapis.com/v0/b/uwin-201010.appspot.com/o/shopTypesIcons%2Ffav.jpeg?alt=media&token=15f994e3-99bd-48ba-b4d6-e3e6148d1356',
    },
    ...shopTypesMap,
    {
      'title': 'All',
      'query': '',
      'asset':
          'https://firebasestorage.googleapis.com/v0/b/uwin-201010.appspot.com/o/shopTypesIcons%2Fall.jpeg?alt=media&token=21733d51-16e5-41fc-b2dc-7b1a7d776824',
    },
  ];
}
