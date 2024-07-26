class MyWinsMenuItem {
  final String id;
  final String title;
  final String unit;
  final String imageUrl;
  final bool published;

  const MyWinsMenuItem({
    this.id,
    this.title,
    this.unit,
    this.imageUrl,
    this.published,
  });

  MyWinsMenuItem.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        unit = data['unit'],
        imageUrl = data['imageUrl'],
        published = data['published'] ?? true;
}
