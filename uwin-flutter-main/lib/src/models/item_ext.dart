class ItemExt {
  final String id;
  final int archivedAt;
  final bool isArchive;
  final String shopId;
  final String category1;
  final String subcategory1;
  final String category2;
  final String subcategory2;
  final int normalPrice;
  final int quantityAvailable;

  ItemExt({
    this.id,
    this.shopId,
    this.archivedAt = 0,
    this.isArchive = false,
    this.category1 = '',
    this.category2 = '',
    this.subcategory1 = '',
    this.subcategory2 = '',
    this.normalPrice = 0,
    this.quantityAvailable = 0,
  });

  ItemExt.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        archivedAt = data['archivedAt'],
        isArchive = data['isArchive'],
        category1 = data['category1'] ?? '',
        category2 = data['category2'] ?? '',
        subcategory1 = data['subcategory1'] ?? '',
        subcategory2 = data['subcategory2'] ?? '',
        shopId = data['shopId'],
        normalPrice = data['normalPrice'] ?? 0,
        quantityAvailable = data['quantityAvailable'] ?? 0;
}
