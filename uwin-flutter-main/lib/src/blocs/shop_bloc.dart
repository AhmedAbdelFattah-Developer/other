import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';
import 'package:uwin_flutter/src/models/shop_ext.dart';
import 'dart:math' as math;
import 'auth_bloc.dart';

import '../models/shop.dart';
import '../models/pos.dart';
import '../models/user.dart';

class ButtonState {
  final String name;

  const ButtonState({this.name});
}

class ButtonStates {
  static const enabled = ButtonState(name: 'enabled');
  static const disabled = ButtonState(name: 'disabled');
  static const spinning = ButtonState(name: 'spinnning');
}

double _calculateDistance(lat1, lon1, lat2, lon2) {
  const p = 0.017453292519943295; // Math.PI / 180
  const c = math.cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;

  return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
}

class _FavoriteRequest {
  final String shopId;
  final bool write;
  final bool value;

  _FavoriteRequest(this.shopId, {this.write = false, this.value});
}

class _FavoriteQuery {
  final User user;
  final _FavoriteRequest request;

  _FavoriteQuery(this.user, this.request);
}

class ShopBloc {
  final _shop = BehaviorSubject<Shop>();
  final _posList = PublishSubject<List<Pos>>();
  final _favoriteRequest = BehaviorSubject<_FavoriteRequest>();
  final _idCardNumber = BehaviorSubject<String>();
  final _showIdCardNumberFormSpinner = BehaviorSubject<bool>();
  final _position = BehaviorSubject<Position>();
  final String endpoint = 'https://u-win.shop/admin/shops';
  final AuthBloc authBloc;
  final _isAdult = BehaviorSubject<bool>();
  final HttpCacheManager cache;
  bool isDev = false;

  ShopBloc(this.authBloc, this.cache) {
    assert(() {
      isDev = true;

      return true;
    }());
  }

  Stream<ShopShopExt> get shopShopExt {
    Shop shop;
    return _shop.switchMap((sh) {
      shop = sh;

      return FirebaseFirestore.instance
          .collection('shopExt')
          .doc(sh.id)
          .snapshots()
          .map((snap) => ShopExt.fromMap(snap.data()));
    }).map((shopExt) {
      return ShopShopExt(ext: shopExt, shop: shop);
    });
  }

  Stream<Map<String, bool>> get buttons {
    return shopShopExt.map((ssExt) {
      return <String, bool>{
        'hasCatalog': ssExt.ext.catalogButton,
        'canBuyOnline': ssExt.ext.onlineCatalogButton && ssExt.shop.hasWebsite,
        'canSellVoucher': ssExt.ext.giftVoucherButton,
        'canBuyNow': ssExt.ext.buyNowButton,
        'buyGiftVouchers': ssExt.shop.id == '5dea544f5f66505bdca3f01f',
      };
    });
  }

  Stream<bool> get haveBottomBar => buttons.map(
        (btns) =>
            btns != null &&
            btns.entries.fold<bool>(
              false,
              (previousValue, element) => previousValue || element.value,
            ),
      );

  Stream<String> get favorite =>
      Rx.combineLatest2<User, _FavoriteRequest, _FavoriteQuery>(
        authBloc.user,
        _favoriteRequest.stream,
        (User u, _FavoriteRequest request) {
          return _FavoriteQuery(u, request);
        },
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: (_FavoriteQuery query, EventSink<String> sink) async {
            sink.add('');
            final favorite = await _fetchFavorite(query);
            sink.add(favorite ? 'on' : 'off');
          },
        ),
      );

  Stream<Shop> get shop => _shop.stream;
  Stream<List<Pos>> get posList => _posList.stream;
  Stream<Shop> get shopWithPos => Rx.combineLatest3(
        shop,
        posList,
        _position.stream,
        (Shop s, List<Pos> pl, Position posi) {
          if (pl.length > 0) {
            pl.forEach((pos) => s.posList.add(pos));
            if (posi.latitude != null && posi.longitude != null) {
              s.posList.sort(
                (a, b) => _calculateDistance(
                        posi.latitude, posi.longitude, a.lat, a.lng)
                    .compareTo(
                  _calculateDistance(
                      posi.latitude, posi.longitude, b.lat, b.lng),
                ),
              );
            }
          }

          return s;
        },
      );

  Stream<bool> get canSellVoucher => _shop.stream.switchMap(
        (sh) => FirebaseFirestore.instance
            .doc('saleVoucherShops/${sh.id}')
            .snapshots()
            .transform<bool>(
              StreamTransformer.fromHandlers(
                handleData: (doc, sink) {
                  sink.add(doc.data().containsKey('enabled')
                      ? doc.data()['enabled']
                      : false);
                },
                handleError: (doc, stackTrace, sink) {
                  sink.add(false);
                },
              ),
            ),
      );

  Stream<bool> get isForAdult => shop
      .switchMap(
        (sh) => FirebaseFirestore.instance.doc('shopExt/${sh.id}').snapshots(),
      )
      .map((doc) => ShopExt.fromMap(doc.data()))
      .map((shExt) => shExt.adult)
      .onErrorReturn(false);

  Stream<bool> get isAdult => _isAdult.stream;

  Stream<bool> get canAccess => Rx.combineLatest2(
        isForAdult,
        isAdult,
        (b1, b2) {
          if (!b1) {
            return true;
          }

          return b2;
        },
      );

  void fetch(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isAdultVal = prefs.getBool('isAdult');
    _isAdult.sink.add(isAdultVal == true);
    _showIdCardNumberFormSpinner.sink.add(false);
    _shop.add(null);
    Future.delayed(Duration(milliseconds: 0),
        () => _favoriteRequest.sink.add(_FavoriteRequest(id)));

    try {
      _position.sink.add(
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(Duration(minutes: 5),
            onTimeout: () => throw 'Current location has timeout'),
      );
    } catch (err) {
      print('[shop_bloc] getCurrentPosition error: $err');
      _position.sink.add(Position(
        speedAccuracy: 0,
        latitude: 0,
        speed: 0,
        floor: 0,
        heading: 0,
        accuracy: 0,
        altitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
      ));
    }

    authBloc.user.listen((User user) async {
      final client = new http.Client();
      String url = '$endpoint/$id';

      try {
        //Fetch shop info
        var res = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': user.token,
          },
        );

        if (res.statusCode != 200) {
          _shop.addError("Could not find shop");

          return;
        }

        final shop = Shop.fromApi(json.decode(utf8.decode(res.bodyBytes)));
        _shop.sink.add(shop);

        //fetch shop pos list
        url = '$endpoint/$id/pos';
        res = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': user.token,
          },
        );

        if (res.statusCode != 200) {
          _shop.addError("Could not find shop");

          return;
        }

        final parsedPosList = List<Map<String, dynamic>>.from(
                json.decode(utf8.decode(res.bodyBytes)))
            .map<Pos>((data) => Pos.fromApi(data))
            .toList();
        _posList.sink.add(parsedPosList);
      } finally {
        client.close();
      }
    });
  }

  setFavorite(String shopId, bool val) {
    Future.delayed(
      Duration(milliseconds: 0),
      () => _favoriteRequest.sink.add(
        _FavoriteRequest(
          shopId,
          write: true,
          value: val,
        ),
      ),
    );
  }

  Future<bool> _fetchFavorite(_FavoriteQuery query) async {
    final client = new http.Client();
    String url =
        'https://u-win.shop/admin/users/${query.user.id}/shops/${query.request.shopId}/favorite';

    try {
      if (query.request.write) {
        var res = await client.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': query.user.token,
          },
          body: json.encode(query.request.value),
        );

        if (res.statusCode != 200) {
          throw 'Server error. Code: ${res.statusCode}';
        }

        return query.request.value;
      } else {
        var res = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': query.user.token,
          },
        );

        if (res.statusCode != 200) {
          throw 'Server error. Code: ${res.statusCode}';
        }

        return json.decode(utf8.decode(res.bodyBytes));
      }
    } finally {
      client.close();
    }
  }

  Stream<bool> get idCardNumberValid => _idCardNumber.map<bool>(
        (id) {
          if (id == null || id.trim().isEmpty || id.length < 7) {
            return null;
          }

          final date = id.substring(1, 3);
          final month = id.substring(3, 5);
          final yearRaw = id.substring(5, 7);
          final year = int.parse(yearRaw) > 30 ? '19$yearRaw' : '20$yearRaw';

          try {
            final value = DateTime.parse('$year-$month-$date');
            return _validateAdult(value);
          } on FormatException {
            print(
                '[ShopBloc.idCardNumberValid] invalid format: $year-$month-$date');
            return false;
          }
        },
      );

  Stream<ButtonState> get idCardNumberFormButtonState => Rx.combineLatest2(
        _showIdCardNumberFormSpinner.stream,
        idCardNumberValid,
        (isSpinning, isValid) {
          if (isSpinning) {
            return ButtonStates.spinning;
          }

          return isValid ? ButtonStates.enabled : ButtonStates.disabled;
        },
      );

  saveIdCardNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAdult', true);
    _isAdult.sink.add(true);
  }

  void Function(String) get changeIdCardNumber => _idCardNumber.sink.add;

  bool _validateAdult(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }

    return age >= 18;
  }

  dispose() {
    _shop.close();
    _posList.close();
    _favoriteRequest.close();
    _position.close();
    _idCardNumber.close();
    _showIdCardNumberFormSpinner.close();
    _isAdult.close();
  }
}
