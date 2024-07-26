class Banner {
  final String downloadUrl;
  final String uri;
  final bool published;

  Banner.fromApi(Map<String, dynamic> data)
      : downloadUrl = data['downloadUrl'],
        uri = data['uri'],
        published = data['published'] ?? false;
}
