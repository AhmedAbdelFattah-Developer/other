class Gender {
  final int id;
  final String label;
  final String title;

  Gender({this.id, this.title, this.label});

  Gender.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        label = data['label'],
        title = data['label'] == 'Woman' ? 'Mrs' : 'Mr';
}
