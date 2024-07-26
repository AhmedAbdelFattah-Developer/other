import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/post.dart';

class PostRepository {
  final CollectionReference collection;

  const PostRepository(this.collection);

  Stream<List<Post>> get howToUseList => collection
      .where('type', isEqualTo: 'how-to-use')
      .snapshots()
      .map<List<Post>>(
        (snap) => snap.docs
            .map(
              (doc) => Post.fromMap(doc.data()),
            )
            .toList()
          ..sort(
            (a, b) => (a.title ?? '').compareTo(b.title ?? ''),
          ),
      );
}
