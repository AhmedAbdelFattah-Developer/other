import 'package:uwin_flutter/src/models/post.dart';
import 'package:uwin_flutter/src/repositories/post_repository.dart';

class HowToUseBloc {
  final PostRepository postRepo;

  const HowToUseBloc(this.postRepo);

  Stream<List<Post>> get posts => postRepo.howToUseList;
}
