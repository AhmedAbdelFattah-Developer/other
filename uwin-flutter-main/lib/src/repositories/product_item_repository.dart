import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/product_item.dart';

class ProductItemRepository {
  Future<Map<String, Map<String, List<ProductItem>>>>
      fetchAllWhereShopByCategory(
    String shopId,
    String uid,
    String token,
  ) async {
    final client = new http.Client();
    final url =
        'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/$uid/shops/$shopId/categories-products-items';

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (res.statusCode != 200) {
        throw "Could not find categories products items";
      }

      final Map<String, dynamic> data = json.decode(utf8.decode(res.bodyBytes));

      return ProductItem.fromCategoryMap(
        Map<String, Map<String, dynamic>>.from(data),
      );
    } finally {
      client.close();
    }
  }
}
