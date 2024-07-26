import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/models/product_item.dart';
import 'package:uwin_flutter/src/repositories/product_item_repository.dart';
import 'auth_bloc.dart';
import '../models/item_ext.dart';
import '../repositories/item_ext_repository.dart';
import '../models/flashsale.dart';
import '../models/shop.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../models/catalog.dart';

class _CatalogQuery {
  final User user;
  final Shop shop;

  _CatalogQuery(this.user, this.shop);
}

class CatalogBloc {
  static const String baseUrl = 'https://u-win.shop/admin/shops';

  final _request = PublishSubject<Shop>();
  final _productItemByCategory =
      PublishSubject<Map<String, Map<String, List<ProductItem>>>>();
  final AuthBloc authBloc;
  final ItemExtRepository itExtRepo = new ItemExtRepository();
  final ProductItemRepository productItemRepo;

  CatalogBloc(this.authBloc, this.productItemRepo);

  Stream<Map<String, Map<String, List<ProductItem>>>>
      get productItemByCategory => _productItemByCategory.stream;

  Stream<Catalog> get catalog => Rx.combineLatest2<User, Shop, _CatalogQuery>(
        authBloc.user,
        _request.stream,
        (User user, Shop shop) {
          return _CatalogQuery(user, shop);
        },
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: (_CatalogQuery query, EventSink<Catalog> sink) async {
            try {
              final itemsExt = await itExtRepo.fetchByShopId(query.shop.id);
              final data = await Future.wait([
                fetchFlashSales(query),
                fetchItems(query, itemsExt),
              ]);
              sink.add(Catalog(flashsales: data[0], items: data[1]));
            } catch (e) {
              sink.addError(e);
            }
          },
        ),
      );

  Future<List<Flashsale>> fetchFlashSales(_CatalogQuery query) async {
    final client = new http.Client();
    final url = '$baseUrl/${query.shop.id}/flashSells';

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': query.user.token,
        },
      );

      if (res.statusCode != 200) {
        throw "Could not find flash sells";
      }

      final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));

      return dataList.map((data) => Flashsale.fromApi(data)).toList();
    } finally {
      client.close();
    }
  }

  Future<List<Item>> fetchItems(
    _CatalogQuery query,
    List<ItemExt> itemsExt,
  ) async {
    final client = new http.Client();
    final url = '$baseUrl/${query.shop.id}/items';

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': query.user.token,
        },
      );

      if (res.statusCode != 200) {
        throw "Could not find flash sells";
      }

      final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));
      final items = dataList.map<Item>((data) => Item.fromApi(data)).toList();

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

  Future<void> fetch(Shop shop) async {
    Future.delayed(Duration(milliseconds: 0), () => _request.sink.add(shop));
    try {
      final user = await authBloc.user.take(1).first;
      final map = await productItemRepo.fetchAllWhereShopByCategory(
        shop.id,
        user.id,
        user.token,
      );
      _productItemByCategory.sink.add(map);
    } catch (err) {
      print(err);
      _productItemByCategory.sink
          .addError('Could not find list of product item by category');
    }
  }

  dispose() {
    _productItemByCategory.close();
    _request.close();
  }
}
