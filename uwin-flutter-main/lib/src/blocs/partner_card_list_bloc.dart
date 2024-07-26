import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/models/shop.dart';

import '../models/loyalty_shop.dart';
import '../repositories/shop_repository.dart';

class UserShopLoyaltyPoints {
  final String memberFirstName;
  final String memberLastName;
  final int point;
  final String shopId;
  final String shopName;
  final String uid;

  UserShopLoyaltyPoints.fromMap(Map<String, dynamic> data)
      : memberFirstName = data['memberFirstName'],
        memberLastName = data['memberLastName'],
        point = data['point'],
        shopId = data['shopId'],
        shopName = data['shopName'],
        uid = data['uid'];
}

class PartnerCardListBloc {
  final ShopRepository shopRepo;
  final AuthBloc authBloc;
  final _shopNames = BehaviorSubject<List<Shop>>();

  PartnerCardListBloc({this.shopRepo, this.authBloc});

  fetch() async {
    try {
      final sn = await shopRepo.fetchActiveShopNames();
      _shopNames.sink.add(sn);
    } catch (err) {
      _shopNames.sink.addError('Could not find shop names');
      print('[partner_card_list_bloc] Could not find shop names. $err');
    }
  }

  Stream<Map<String, int>> get loyaltyShopPoints => authBloc.user.switchMap(
        (u) => FirebaseFirestore.instance
            .collection('userShopLoyaltyPoints')
            .where('uid', isEqualTo: u.id)
            .snapshots()
            .map((snap) => snap.docs
                .map<UserShopLoyaltyPoints>(
                  (doc) => UserShopLoyaltyPoints.fromMap(doc.data()),
                )
                .toList())
            .map(
              (points) => Map<String, int>.fromEntries(
                points.map(
                  (point) => MapEntry(point.shopId, point.point),
                ),
              ),
            ),
      );

  Stream<List<LoyaltyShop>> get loyaltyShops =>
      Rx.combineLatest2<List<String>, List<Shop>, List<LoyaltyShop>>(
        shopRepo.fetchLoyaltyShopId(),
        _shopNames.stream,
        (ids, names) {
          return ids
              .map((id) {
                final shop = names.firstWhere(
                  (sh) => sh.id == id,
                  orElse: () => null,
                );

                if (shop == null) {
                  return null;
                }

                return LoyaltyShop(
                  name: shop.name,
                  shopId: shop.id,
                  points: 0,
                  // logoUrl: shop.photoPath,
                );
              })
              .where((ls) => ls != null)
              .toList();
        },
      );

  dispose() {
    _shopNames.close();
  }
}
