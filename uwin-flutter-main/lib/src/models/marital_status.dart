class MaritalStatus {
  final int id;
  final String label;

  MaritalStatus({this.id, this.label});

  MaritalStatus.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        label = data['label'];
}
