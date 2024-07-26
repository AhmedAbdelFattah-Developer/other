import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/models/shop_type.dart';
import 'package:uwin_flutter/src/repositories/shop_type_repository.dart';
import 'package:http/http.dart' as http;

class HomeBloc {
  final ShopTypeRepository shopTypeRepository;

  HomeBloc(this.shopTypeRepository);

  Stream<Map<String, num>> get voucherPerCategory =>
      fetchVoucherPerCategory().asStream();

  Stream<List<ShopType>> get shopTypeList => shopTypeRepository.fetchAll();
  void dispose() {}

  Future<Map<String, num>> fetchVoucherPerCategory() async {
    final uid = "5e3186275f665079a5a59f31";
    final httpClient = http.Client();
    final res = await httpClient.get(Uri.parse(
        "https://u-win.shop/admin/users/$uid/vouchers-with-shop-type"));
    if (res.statusCode != 200) {
      throw StateError("Server Error: ${res.body}");
    }

    final list = List<Map<String, dynamic>>.from(json.decode(res.body));
    final splitted = <String, List<num>>{};
    for (final it in list) {
      if (splitted[it['shopType']] == null) {
        splitted[it['shopType']] = <num>[];
      }

      splitted[it['shopType']].add(it['amount']);
    }

    final voucherByCategories = splitted.map<String, num>(
        (shopType, listAmount) =>
            MapEntry(shopType, listAmount.reduce((acc, it) => acc + it)));
    debugPrint('#################');
    debugPrint(voucherByCategories.toString());

    return voucherByCategories;
  }
}
