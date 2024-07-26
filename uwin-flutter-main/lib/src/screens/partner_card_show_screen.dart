import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/ItemTile.dart';
import '../blocs/partner_card_show_bloc.dart';
import '../models/shop.dart';
import '../models/item.dart';

class PartnerCardShowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PartnerCardShowBloc>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: StreamBuilder<Shop>(
          stream: bloc.shop,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return Container();
            }

            return Text(snapshot.data.name);
          },
        ),
      ),
      child: StreamBuilder<int>(
          stream: bloc.points,
          builder: (context, snapshot) {
            return _buildBody(context, snapshot);
          }),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<int> points) {
    final bloc = Provider.of<PartnerCardShowBloc>(context);

    return StreamBuilder<Shop>(
      stream: bloc.shop,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CupertinoActivityIndicator());
        }

        final theme = CupertinoTheme.of(context);

        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _buildPointsBox(
                  theme,
                  context,
                  snapshot.data,
                  points,
                ),
              ),
              __buildItemGrid(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointsBox(
    CupertinoThemeData theme,
    BuildContext context,
    Shop shop,
    AsyncSnapshot<int> points,
  ) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x3C000000),
              offset: Offset(2.0, 2.0),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Card(
          color: theme.primaryColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                _buildLogo(context, shop),
                SizedBox(width: 20.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Fidelity Card',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    _buildPoints(points)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoints(AsyncSnapshot<int> snapshot) {
    final style = TextStyle(
      fontSize: 14.0,
      color: Colors.white.withAlpha(200),
    );

    if (snapshot.hasError) {
      print('${snapshot.error}');

      return Text('Error');
    }

    print('snapshot.data: ${snapshot.data}');

    if (!snapshot.hasData) {
      return Text('...', style: style);
    }

    return Text(
      '${snapshot.data} Points',
      style: style,
    );
  }

  Widget _buildLogo(BuildContext context, Shop shop) {
    final decorationImage = shop.logoUrl != null
        ? DecorationImage(
            fit: BoxFit.contain,
            image: NetworkImage(
                'https://u-win.shop/files/shops/${shop.id}/${shop.logoUrl}'),
          )
        : null;

    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          color: Colors.white,
          image: decorationImage),
    );
  }

  Widget __buildItemGrid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 200).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 245;
    final tileAspectRatio = tileWidth / tileHeight;

    return StreamBuilder<List<Item>>(
        stream: Provider.of<PartnerCardShowBloc>(context).items,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SliverToBoxAdapter(
              child: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CupertinoActivityIndicator(),
                ),
              ),
            );
          }

          if (snapshot.data.length == 0) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Text('No item available yet. Please try later.'),
                ),
              ),
            );
          }

          return SliverPadding(
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: tileAspectRatio,
              ),
              delegate: SliverChildListDelegate(snapshot.data
                  .map<Widget>(
                    (Item it) => ItemTile(
                      it.shopId,
                      it,
                      points: true,
                    ),
                  )
                  .toList()),
            ),
            padding: EdgeInsets.all(20.0),
          );
        });
  }
}
