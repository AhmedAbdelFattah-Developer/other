import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';
import 'package:uwin_flutter/src/models/shop_type.dart';
import 'package:uwin_flutter/src/repositories/shop_type_repository.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'dart:convert';

import 'auth_bloc.dart';
import '../models/pos.dart';

const _defaultCacheTimeout = 72;
const _posListKey = 'query-pos-list-by-category';

class PosQueryBloc {
  final AuthBloc authBloc;
  final VoucherRepository voucherRepo;
  final PublishSubject<List<Pos>> _posList = PublishSubject<List<Pos>>();
  final HttpCacheManager cache;
  final _vouchers = BehaviorSubject<List<Voucher>>();
  final String endpoint =
      'https://u-win.shop/admin/users/{id}/queryPosResource';
  final ShopTypeRepository shopTypeRepository;

  PosQueryBloc(
    this.authBloc,
    this.cache,
    this.voucherRepo,
    this.shopTypeRepository,
  );

  Stream<List<ShopType>> get shopTypeList => shopTypeRepository.fetchAll();

  Stream<List<Pos>> get posList => _posList.stream;

  Stream<List<Voucher>> get voucherList => _posList
      .startWith(null)
      .switchMap((list) => fetchVouchers(list).asStream());

  Future<Map<String, dynamic>> _buildBody(
      String cityId, String category, String query) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(Duration(seconds: 5),
              onTimeout: () => throw 'Could not find position');

      return {
        'lat': position.latitude,
        'lng': position.longitude,
        'shopTypeStr': category,
        "textSearch": query,
      };
    } catch (e) {
      print('[pos_query_bloc] Could not get curren tocation');
      print('[pos_query_bloc] $e');
      return {
        'idCity': cityId,
        'shopTypeStr': category,
        "textSearch": query,
      };
    }
  }

  String currentCategory;

  fetch(String category, {String query = ''}) async {
    if (category == 'Favourite') {
      try {
        final list = await _fetchFavourite();
        _posList.add(list);
      } catch (err) {
        if (err is StateError) {
          _posList.addError(err.message);
        } else {
          _posList.addError('$err');
        }
      }

      return;
    }

    final hasQuery = query == null || query.isEmpty;
    currentCategory = category;
    final user = authBloc.currentUser;
    String url = endpoint.replaceFirst('{id}', user.id);
    debugPrint('[pos_query_bloc] url: $url');

    if (hasQuery) {
      final cached = await cache.getData(getCacheKey(category));
      if (cached != null &&
          !cached.hasExpired(Duration(hours: _defaultCacheTimeout))) {
        final dataList =
            List<Map<String, dynamic>>.from(json.decode(cached.data));

        if (currentCategory == category) {
          _posList.sink.add(
            dataList.map((data) => Pos.fromApi(data)).toList(),
          );
        }
      }
    } else {
      _posList.addError('loading');
    }

    final profile = authBloc.currentProfile;

    final body = await _buildBody(profile.cityId, category, query);
    debugPrint('[pos_query_bloc] request body: ${json.encode(body)}');
    final client = new http.Client();
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
        debugPrint(res.body);
        _posList.addError("Could not find shop");

        return;
      }
      debugPrint('[pos_query_bloc] res body: ${res.body}');

      final rawData = utf8.decode(res.bodyBytes);
      final dataList = List<Map<String, dynamic>>.from(
        json.decode(rawData),
      );
      await cache.setData(getCacheKey(category), rawData);

      if (currentCategory == category) {
        final plist = dataList.map((data) => Pos.fromApi(data)).toList();
        _posList.sink.add(plist);
      }
    } finally {
      client.close();
    }
  }

  Future<List<Voucher>> fetchVouchers(List<Pos> posList) async {
    final user = await authBloc.user.take(1).first;
    final vouchers = await voucherRepo.fetchVoucher(user.token, user.id);
    vouchers.sort(
      (a, b) => a.shopName.toLowerCase().compareTo(
            b.shopName.toLowerCase(),
          ),
    );

    if (posList == null || posList.isEmpty) {
      return vouchers;
    }

    return vouchers.where((v) {
      for (final pos in posList) {
        if (pos.shop?.id == v.shopId) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Timer t;

  changeQuery(String category, String value) {
    _posList.sink.add(null);
    if (t != null && t.isActive) {
      t.cancel();
    }

    t = Timer(Duration(milliseconds: 800), () => fetch('', query: value));
  }

  String getCacheKey(String category) {
    if (category == null) {
      return _posListKey;
    }

    return '$_posListKey-$category';
  }

  Future<List<Pos>> _fetchFavourite() async {
    final user = authBloc.currentUser;
    final profile = authBloc.currentProfile;
    final body = await _buildBody(profile.cityId, '', '');
    final client = new http.Client();
    String url = endpoint.replaceFirst('{id}', user.id);
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
        throw StateError("Could not find shop");
      }

      final rawData = utf8.decode(res.bodyBytes);
      return List<Map<String, dynamic>>.from(
        json.decode(rawData),
      ).map((data) => Pos.fromApi(data)).where((pos) => pos.favorite).toList();
    } finally {
      client.close();
    }
  }

  dispose() {
    _vouchers.close();
  }
}
