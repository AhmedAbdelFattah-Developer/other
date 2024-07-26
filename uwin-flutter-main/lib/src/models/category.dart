class Category {
  final String id;
  final String name;

  Category({this.id, this.name});

  Category.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'];
}
