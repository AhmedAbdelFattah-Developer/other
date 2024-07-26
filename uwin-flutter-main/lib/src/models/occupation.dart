class Occupation {
  final int id;
  final String label;

  Occupation({this.id, this.label});

  Occupation.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        label = data['label'];
}
