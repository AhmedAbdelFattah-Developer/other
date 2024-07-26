import 'dart:typed_data';

import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/models/other_card.dart';
import 'package:uwin_flutter/src/repositories/other_card_repository.dart';
import 'package:rxdart/rxdart.dart';

class MyWinOtherCardDetailsBloc {
  final AuthBloc authBloc;
  final OtherCardRepository repo;

  MyWinOtherCardDetailsBloc(this.authBloc, this.repo);

  Stream<OtherCard> find(String id) =>
      authBloc.user.switchMap((u) => repo.find(u.id, id));

  Future<String> uploadImage(String id, String context, Uint8List bytes) async {
    return repo.uploadImage(
      authBloc.currentUser.id,
      '${context}_$id.jpeg',
      bytes,
    );
  }

  Future<void> saveImage(CardSide side, String id, String path) =>
      repo.saveCardImage(side, authBloc.currentUser.id, id, path);

  Future<void> delete(String id) {
    return repo.delete(authBloc.currentUser.id, id);
  }

  Future<void> saveCode(String id, String code) {
    return repo.saveCode(authBloc.currentUser.id, id, code);
  }

  Future<void> saveLabel(String id, String label) {
    return repo.saveLabel(authBloc.currentUser.id, id, label);
  }

  void dispose() {}
}
