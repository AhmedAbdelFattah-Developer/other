import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:uwin_flutter/src/models/user.dart';

import 'auth_bloc.dart';
import '../repositories/shop_repository.dart';
import '../models/shop.dart';
import '../models/item.dart';

class PartnerCardShowBloc {
  final _shop = PublishSubject<Shop>();
  final _items = BehaviorSubject<List<Item>>();
  final ShopRepository shopRepo;
  final AuthBloc authBloc;

  PartnerCardShowBloc({@required this.shopRepo, @required this.authBloc});

  Stream<Shop> get shop => _shop.stream;
  Stream<List<Item>> get items => _items.stream;
  Stream<int> get points => Rx.combineLatest2<User, Shop, Map<String, dynamic>>(
        authBloc.user,
        _shop.stream,
        (a, b) => {'user': a, 'shop': b},
      ).switchMap(
        (combined) {
          final User u = combined['user'];
          final Shop sh = combined['shop'];
          print('u: ${u.id}');
          print('sh: ${sh.id}');

          return FirebaseFirestore.instance
              .collection('userShopLoyaltyPoints')
              .doc('${u.id}.${sh.id}')
              .snapshots()
              .map(
            (snap) {
              print('snap.exists: ${snap.exists}');
              if (!snap.exists) {
                return 0;
              }

              return snap.data()['point'] ?? 0;
            },
          );
        },
      );

  fetch(String id) async {
    _items.sink.add(null);
    String token;

    try {
      token = await authBloc.token;
    } catch (err) {
      print('[partner_card_show_bloc] Could get auth token');
      print(err);
      _shop.sink.addError('An unexpected error has occured.');

      return;
    }

    try {
      final shop = await shopRepo.fetch(token, id);
      _shop.sink.add(shop);
    } catch (err) {
      _shop.sink.addError('Could not find shop');
      print('[partner_card_show_bloc] Error: $err');
    }

    try {
      final items = await shopRepo.fetchLoyaltyItems(id, token);
      _items.sink.add(items);
    } catch (err) {
      print('[partner_card_show_bloc] Could not find items for shop $id');
      print(err);
      _items.sink.addError('Could not find items for this shop');
    }
  }

  dispose() {
    _shop.close();
    _items.close();
  }
}
