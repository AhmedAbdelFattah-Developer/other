class Coupon {
  final String itemId;
  final String id;
  final String name;
  final String photoPath;
  final int validity;
  final double discountValue;
  final String itemName;
  final double itemPrice;
  final String itemPhotoPath;
  final String shopId;
  final String shopName;
  final int usedDate;

  Coupon(
    this.id,
    this.itemId,
    this.name,
    this.photoPath,
    this.validity,
    this.discountValue,
    this.itemName,
    this.itemPrice,
    this.itemPhotoPath,
    this.shopId,
    this.shopName,
    this.usedDate,
  );

  Coupon.fromApi(Map<String, dynamic> data)
      : itemId = data['idItem'],
        id = data['id'],
        name = data['name'],
        photoPath = data['photoPath'] ?? '',
        validity = data['validity'],
        discountValue = data['discountValue'],
        itemName = data['nameItem'],
        itemPrice = data['priceItem'],
        itemPhotoPath = data['photoPathItem'] ?? '',
        shopId = data['idShop'],
        usedDate = data['usedDate'],
        shopName = data['nameShop'];

  double get itemDiscountedPrice => (itemPrice - discountValue);
}
