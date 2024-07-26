class ShopType {
  final String id;
  final String name;
  final bool publishedOnUwin;
  final String imageUrl;
  final String iconUrl;
  final int position;

  const ShopType({
    this.id,
    this.name,
    this.publishedOnUwin,
    this.imageUrl,
    this.iconUrl,
    this.position,
  });

  ShopType.fromMap(Map<String, dynamic> data)
      : id = data['id'] ?? '',
        name = data['name'] ?? '',
        publishedOnUwin = data['publishedOnUwin'] ?? false,
        imageUrl = data['imageUrl'] ?? '',
        iconUrl = data['iconUrl'] ?? '',
        position = data['position'] ?? 0;
}
