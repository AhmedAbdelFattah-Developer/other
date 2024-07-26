import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';
import 'package:uwin_flutter/src/models/banner.dart';
import 'package:uwin_flutter/src/models/flashsale.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/repositories/banner_repository.dart';

const _defaultCacheTimeout = 72;
const _flashsellsKey = 'home-flashsells';
const _shopListKey = 'home-pos-list';

class FlashsellsBloc {
  final HttpCacheManager cache;
  final _posListRequest = PublishSubject<bool>();
  final PublishSubject<Map<String, List<Flashsale>>> _flashsells =
      PublishSubject<Map<String, List<Flashsale>>>();
  final BehaviorSubject<bool> _fromGeolocaltion = BehaviorSubject<bool>();
  final AuthBloc authBloc;
  final _shopList = BehaviorSubject<List<Shop>>();
  final BannerRepository bannerRepo;

  static const String posListEndpoint =
      'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/{id}/featured-shops';
  static const String baseUrl = 'https://u-win.shop/users';
  static const String endNode = 'flashSellsPosition';

  FlashsellsBloc(this.authBloc, this.cache, this.bannerRepo);

  Stream<Map<String, List<Flashsale>>> get flashsells => _flashsells.stream;
  Stream<bool> get fromGeolocaltion => _fromGeolocaltion.stream;

  // Filter out non premium shop
  Stream<List<Shop>> get shopList => _shopList.stream;

  Stream<Banner> get homeBanner => bannerRepo.find();

  Future<List<Shop>> fetchShop(UserProfile userProfile) async {
    final user = userProfile.user;

    final client = http.Client();
    String url = posListEndpoint.replaceFirst('{id}', user.id);
    try {
      var res = await client.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': user.token,
      });

      if (res.statusCode != 200) {
        throw "Server error. Error code: ${res.statusCode}";
      }

      final rawData = utf8.decode(res.bodyBytes);
      final dataList = List<Map<String, dynamic>>.from(json.decode(rawData));
      await cache.setData(_shopListKey, rawData);

      return dataList.map((data) => Shop.fromApi(data)).toList();
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _buildBody(String cityId) async {
    try {
      LocationPermission geolocationStatus = await Geolocator.checkPermission();
      if (geolocationStatus == LocationPermission.denied) {
        _fromGeolocaltion.add(false);

        return {'idCity': cityId};
      }

      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low)
          .timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw 'getCurrentPosition timeout(5)';
        },
      );

      _fromGeolocaltion.sink.add(true);

      return {
        'lat': position.latitude,
        'lng': position.longitude,
      };
    } catch (err) {
      _fromGeolocaltion.add(false);

      return {'idCity': cityId};
    }
  }

  void initFlashsells() {
    // listen to user
    authBloc.user.listen((user) async {
      final String url = '$baseUrl/${user.id}/$endNode';

      //fetch from cache first then load data from network
      final cacheData = await cache.getData(_flashsellsKey);

      if (cacheData != null &&
          !cacheData.hasExpired(Duration(hours: _defaultCacheTimeout))) {
        final List<dynamic> dataWrapper = json.decode(cacheData.data);

        if (dataWrapper.length == 0) {
          _flashsells.addError("No flash sells available");
        }

        final List<Map<String, dynamic>> favData =
            List<Map<String, dynamic>>.from(dataWrapper.first);

        final List<Flashsale> fav =
            favData.map((d) => Flashsale.fromApi(d)).toList();

        final List<Map<String, dynamic>> locData =
            List<Map<String, dynamic>>.from(dataWrapper.last);

        final List<Flashsale> loc =
            locData.map((d) => Flashsale.fromApi(d)).toList();

        _flashsells.sink.add({
          'fav': fav,
          'loc': loc,
        });
      }

      final body = await _buildBody(authBloc.currentProfile.cityId);
      final client = http.Client();

      try {
        var res = await client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': user.token,
          },
          body: json.encode(body),
        );

        if (res.statusCode != 200) {
          _flashsells.addError("Could not find flash sells");

          return;
        }

        final rawData = utf8.decode(res.bodyBytes);
        final List<dynamic> dataWrapper = json.decode(rawData);

        if (dataWrapper.length == 0) {
          _flashsells.addError("No flash sells available");
        }

        final List<Map<String, dynamic>> favData =
            List<Map<String, dynamic>>.from(dataWrapper.first);

        final List<Flashsale> fav =
            favData.map((d) => Flashsale.fromApi(d)).toList();

        final List<Map<String, dynamic>> locData =
            List<Map<String, dynamic>>.from(dataWrapper.last);

        final List<Flashsale> loc =
            locData.map((d) => Flashsale.fromApi(d)).toList();

        _flashsells.sink.add({
          'fav': fav,
          'loc': loc,
        });

        cache.setData(_flashsellsKey, rawData);
      } finally {
        client.close();
      }
    });
  }

  void fetch() async {
    initFlashsells();

    await Future.wait([
      initShopList(),
    ]);
  }

  Future<void> initShopList() async {
    authBloc.userProfile.take(1).listen((up) async {
      // final cached = await cache.getData(_shopListKey);

      // if (cached != null &&
      //     !cached.hasExpired(Duration(hours: _defaultCacheTimeout))) {
      //   final cachedDataList =
      //       List<Map<String, dynamic>>.from(json.decode(cached.data));

      //   _shopList.sink.add(cachedDataList
      //       .map((data) {
      //         return Pos.fromApi(data);
      //       })
      //       .toList()
      //       .where((pos) =>
      //           pos.shop.shopTypeName != 'Services Directory' &&
      //           pos.shop.shopTypeName != 'Community')
      //       .toList());
      // }

      try {
        _shopList.sink.add(await fetchShop(up));
      } catch (err) {
        print('Could not fetch shops');
        print(err);
        _shopList.sink.addError('Could not fetch shops');
      }
    });
  }

  Future fetchPosList() {
    return Future.delayed(
      Duration(milliseconds: 0),
      () => _posListRequest.sink.add(true),
    );
  }

  dispose() {
    _flashsells.close();
    _posListRequest.close();
    _shopList.close();
  }
}
