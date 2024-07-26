import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/repositories/item_ext_repository.dart';
import '../models/item_ext.dart';
import '../models/item.dart';
import '../models/shop_ext.dart';
import '../models/shop.dart';
import '../models/flashsale.dart';
import '../models/pos.dart';

const _endpoint = 'https://u-win.shop/admin/shops';

class ShopRepository {
  final ItemExtRepository itExtRepo = new ItemExtRepository();

  Future<List<Pos>> fetchByType(
    String userId,
    String typeName,
    String token,
  ) async {
    final client = new http.Client();
    String url = 'https://u-win.shop/admin/users/$userId/queryPosResource';
    try {
      var res = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode(<String, dynamic>{
          'idCity': '',
          'shopTypeStr': typeName,
          'textSearch': '',
        }),
      );

      if (res.statusCode != 200) {
        print('[shop_repository] Could not find shops by type.');
        print('[shop_repository] Server respond with code ${res.statusCode}');
        print('[shop_repository] ${res.body}');

        throw "Could not find shops";
      }

      final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));

      return dataList.map((data) => Pos.fromApi(data)).toList();
    } finally {
      client.close();
    }
  }

  Future<Shop> fetch(String token, String id) async {
    final client = new http.Client();
    String url = '$_endpoint/$id';

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (res.statusCode != 200) {
        print('[shop_repository] ${res.body}');
        throw "Could not find shop";
      }

      return Shop.fromApi(json.decode(utf8.decode(res.bodyBytes)));
    } finally {
      client.close();
    }
  }

  Stream<ShopExt> fetchExt(String shopId) {
    return FirebaseFirestore.instance
        .doc('shopExt/$shopId')
        .snapshots()
        .map((snap) => ShopExt.fromMap(snap.data()));
  }

  Future<List<Flashsale>> fetchFlashSales(String token, String id) async {
    final client = http.Client();
    try {
      final url = 'https://u-win.shop/admin/shops/$id/flashSells';
      final res = await client.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });
      final data = json.decode(utf8.decode(res.bodyBytes));

      if (res.statusCode != 200) {
        throw data;
      }

      return List<Map<String, dynamic>>.from(data)
          .map<Flashsale>((it) => Flashsale.fromApi(it))
          .where((fs) => fs.running == true)
          .toList();
    } finally {
      client.close();
    }
  }

  Future<Pos> fetchPos(String id, String posId, String token) async {
    final client = http.Client();
    try {
      final url = 'https://u-win.shop/admin/shops/$id/pos';
      final res = await client.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });
      final data = json.decode(utf8.decode(res.bodyBytes));

      if (res.statusCode != 200) {
        throw data;
      }

      return List<Map<String, dynamic>>.from(data)
          .map<Pos>((pos) => Pos.fromApi(pos))
          .firstWhere((pos) => pos.id == posId);
    } finally {
      client.close();
    }
  }

  Stream<List<String>> fetchLoyaltyShopId() {
    return FirebaseFirestore.instance
        .collection('shopExt')
        .where('hasLoyalty', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ShopExt.fromMap(doc.data()),
              )
              .toList(),
        )
        .map(
          (shopExts) => shopExts.map((shopExt) => shopExt.id).toList(),
        );
  }

  Future<List<Item>> fetchItems(String shopId, String token) async {
    List<ItemExt> itemsExt;

    try {
      itemsExt = await itExtRepo.fetchByShopId(shopId);
    } catch (err) {
      print(
          '[shop_repository] could not find itemExt list for the shop $shopId');

      return null;
    }

    final client = new http.Client();
    final url = '$_endpoint/$shopId/items';

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (res.statusCode != 200) {
        throw "Could not find flash sells";
      }

      final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));
      final items = dataList
          .map((data) {
            data['shopId'] = shopId;

            return data;
          })
          .map<Item>((data) => Item.fromApi(data))
          .toList();

      // Filter out archive products
      return items.where(
        (it) {
          try {
            final itExt = itemsExt.firstWhere((itExt) => it.id == itExt.id);

            return !itExt.isArchive;
          } catch (err) {
            return true;
          }
        },
      ).toList();
    } finally {
      client.close();
    }
  }

  Future<List<Item>> fetchLoyaltyItems(String shopId, String token) async {
    try {
      final shopExtDoc =
          await FirebaseFirestore.instance.doc('shopExt/$shopId').get();
      final shopExt = ShopExt.fromMap(shopExtDoc.data());

      if (shopExt.loyaltyShopId == null || shopExt.loyaltyShopId.isEmpty) {
        print('[shop_repository] Could not fetch shop loyalty id for $shopId');

        return [];
      }

      return fetchItems(shopExt.loyaltyShopId, token);
    } catch (err) {
      print('[shop_repository] Could not fetch shop extension for $shopId');
      print(err);

      return null;
    }
  }

  Future<List<Shop>> fetchActiveShopNames() async {
    final client = http.Client();
    try {
      final url = 'https://us-central1-uwin-201010.cloudfunctions.net' +
          '/loyaltyShopList';
      final res = await client.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
      });
      final data = json.decode(utf8.decode(res.bodyBytes));

      if (res.statusCode != 200) {
        throw data;
      }

      return List<Map<String, dynamic>>.from(data)
          .map<Shop>((sh) => Shop(id: sh['shopId'], name: sh['name']))
          .toList();
    } finally {
      client.close();
    }
  }
}
