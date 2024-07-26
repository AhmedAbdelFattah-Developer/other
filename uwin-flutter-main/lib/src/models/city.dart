class City {
  final String id;
  final String name;
  final String district;

  City({this.id, this.name, this.district});

  City.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        district = data['district'];
}
