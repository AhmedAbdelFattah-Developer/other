import 'package:uwin_flutter/src/models/item_ext.dart';

class Item {
  final String id;
  final String name;
  final String photoPath;
  final double price;
  final String description;
  final String shopId;
  final ItemExt ext;

  const Item({
    this.id,
    this.name,
    this.photoPath,
    this.description,
    this.price,
    this.shopId,
    this.ext,
  });

  Item.withExt(Item item, ItemExt _ext)
      : id = item.id,
        name = item.name,
        photoPath = item.photoPath,
        description = item.description,
        price = item.price,
        shopId = item.shopId,
        ext = _ext;

  Item.fromApi(Map<String, dynamic> data, {String opShopId = ''})
      : id = data['id'],
        name = data['name'],
        photoPath = data['photoPath'],
        price = double.parse('${data['price']}'),
        shopId = data['shopId'] == null ? opShopId : data['shopId'],
        description = data['description'],
        ext = null;

  Map<String, dynamic> get toMap => {
        'id': id,
        'name': name,
        'photoPath': photoPath,
        'price': price,
        'description': description,
        'shopId': shopId,
      };

  int get priceCurrency => (price * 100).round();

  bool hasCategory(String cat) {
    if (ext == null) {
      return false;
    }

    return ext.category1 == cat || ext.category2 == cat;
  }

  bool get hasNormalPrice => ext != null && price*100 < ext.normalPrice;
}
