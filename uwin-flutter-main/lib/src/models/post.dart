class Post {
  final String id;
  final String title;
  final String videoId;

  Post({this.id, this.title, this.videoId});

  Post.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        videoId = data['videoId'];
}
