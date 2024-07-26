class Transportation {
  final int id;
  final String label;

  Transportation({this.id, this.label});

  Transportation.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        label = data['label'];
}
