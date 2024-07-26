import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/repositories/shop_repository.dart';
import '../models/item.dart';
import '../models/item_ext.dart';
import 'item_ext_repository.dart';

const String _baseUrl = 'https://u-win.shop/admin/shops';

class ItemRepository {
  final ItemExtRepository _itemExtRepo;
  final ShopRepository _shopRepository;

  ItemRepository(this._itemExtRepo, this._shopRepository);

  Future<List<Item>> fetchAllByshop(String shopId, String token) async {
    final client = new http.Client();
    final url = '$_baseUrl/$shopId/items';

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

      return dataList
          .map<Item>((data) => Item.fromApi(data, opShopId: shopId))
          .toList();
    } finally {
      client.close();
    }
  }

  Stream<List<Item>> fetchPublishByShop(String shopId, String token) {
    return Rx.combineLatest2<List<ItemExt>, List<Item>, List<Item>>(
      // Merge Item & Item Ext
      _itemExtRepo.fetchByShopIdStream(shopId),
      fetchAllByshop(shopId, token).asStream(),
      (itemsExt, items) => items
          .map(
            (it) => Item.withExt(
              it,
              itemsExt.firstWhere((itExt) => itExt.id == it.id,
                  orElse: () => ItemExt(shopId: shopId, id: it.id)),
            ),
          )
          .toList(),
    ).map((its) => its
        .where((it) => !it.ext.isArchive)
        .toList()); // Filter out archive items
  }

  Stream<List<Item>> fetchAllLogisticProviderItems(
    String userId,
    String token, {
    String typeName = 'Logistic Provider',
  }) {
    return Stream.fromFuture(
      _shopRepository.fetchByType(
        userId,
        typeName,
        token,
      ),
    ).switchMap<List<Item>>(
      (listPos) {
        return Rx.combineLatest<List<Item>, List<Item>>(
          listPos
              .map<Stream<List<Item>>>(
                (pos) => fetchPublishByShop(pos.shop.id, token),
              )
              .toList(),
          (listListItem) => listListItem
              .fold<Map<String, Item>>(
                <String, Item>{}, // use map to remove duplicate entries
                (acc, items) {
                  for (final it in items) {
                    acc[it.id] = it;
                  }

                  return acc;
                },
              )
              .values
              .toList(),
        );
      },
    );
  }
}
