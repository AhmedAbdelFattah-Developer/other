import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';

import '../models/loyalty_shop.dart';
import '../blocs/partner_card_list_bloc.dart';

class PartnerCardListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<PartnerCardListBloc>(context);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        middle: Text('Card List'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pushNamed('/partners_cards/new');
          },
          child: Text('Add Card'),
        ),
      ),
      child: StreamBuilder<Map<String, int>>(
        stream: bloc.loyaltyShopPoints,
        builder: (context, snapshot) => _buildList(
          bloc,
          snapshot.data,
        ),
      ),
    );
  }

  StreamBuilder<List<LoyaltyShop>> _buildList(
      PartnerCardListBloc bloc, Map<String, int> points) {
    return StreamBuilder<List<LoyaltyShop>>(
      stream: bloc.loyaltyShops,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('${snapshot.error}', textAlign: TextAlign.center));
        }

        if (!snapshot.hasData) {
          return Center(child: CupertinoActivityIndicator());
        }

        return Material(
          child: ListView.separated(
            itemBuilder: (context, index) => ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  generateURL(context, snapshot.data[index].shopId),
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(snapshot.data[index].name),
              subtitle: points == null
                  ? Text('...')
                  : Text(points.containsKey(snapshot.data[index].shopId)
                      ? '${points[snapshot.data[index].shopId]} Point(s)'
                      : '0 Point'),
              trailing: Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.of(context).pushNamed('/partners_cards/show',
                    arguments: <String, dynamic>{
                      'shopId': snapshot.data[index].shopId,
                    });
              },
            ),
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data.length,
          ),
        );
      },
    );
  }
}

String generateURL(BuildContext context, String shopId) {
  final token = Provider.of<AuthBloc>(context, listen: false).currentUser.token;
  return 'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/shops/$shopId/logo?token=$token';
}
