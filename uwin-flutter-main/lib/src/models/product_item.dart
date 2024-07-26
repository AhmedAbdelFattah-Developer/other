import 'package:uwin_flutter/src/models/item.dart';

class ProductItem {
  final String id;
  final String shopId;
  final String name;
  final String photoPath;
  final double price;
  final String description;
  final int archivedAt;
  final bool isArchive;
  final String category1;
  final String subcategory1;
  final String category2;
  final String subcategory2;
  final int normalPrice;
  final int quantityAvailable;

  ProductItem.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        shopId = data['shopId'],
        name = data['name'],
        photoPath = data['photoPath'],
        price = double.parse('${data['price']}'),
        description = data['description'],
        archivedAt = data['archivedAt'],
        isArchive = data['isArchive'],
        category1 = data['category1'],
        subcategory1 = data['subcategory1'],
        category2 = data['category2'],
        subcategory2 = data['subcategory2'],
        normalPrice = data['normalPrice'],
        quantityAvailable = data['quantityAvailable'];

  Item toItem() {
    return Item(
      id: id,
      name: name,
      photoPath: photoPath,
      price: price,
      description: description,
      shopId: shopId,
    );
  }

  static Map<String, Map<String, List<ProductItem>>> fromCategoryMap(
    Map<String, Map<String, dynamic>> data,
  ) =>
      data.map(
        (cat, catVal) => MapEntry(
          cat,
          catVal.map(
            (subcat, prods) => MapEntry(
              subcat,
              List<Map<String, dynamic>>.from(prods)
                  .map((prodData) => ProductItem.fromMap(prodData))
                  .toList(),
            ),
          ),
        ),
      );
}
