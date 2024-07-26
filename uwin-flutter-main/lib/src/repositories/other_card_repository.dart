import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/other_card.dart';
import 'package:http_parser/http_parser.dart';

class OtherCardRepository {
  final CollectionReference parent;
  static const collectionName = 'otherCards';

  OtherCardRepository(this.parent);

  String createId(String uid) {
    return parent.doc(uid).collection(collectionName).doc().id;
  }

  Stream<List<OtherCard>> findByUser(String uid) =>
      parent.doc(uid).collection(collectionName).snapshots().map((snap) =>
          snap.docs.map((doc) => OtherCard.fromMap(doc.data())).toList());

  Future<void> save(String uid, String id, String label, String number) async {
    await parent
        .doc(uid)
        .collection(collectionName)
        .doc(id)
        .set(OtherCard(id: id, uid: uid, number: number, label: label).toMap());
  }

  Stream<OtherCard> find(String uid, String id) => parent
      .doc(uid)
      .collection(collectionName)
      .doc(id)
      .snapshots()
      .map((doc) => OtherCard.fromMap(doc.data()));

  Future<OtherCard> findOne(String uid, String id) async {
    final snap = await parent.doc(uid).collection(collectionName).doc(id).get();

    if (!snap.exists) {
      return null;
    }

    return OtherCard.fromMap(snap.data());
  }

  Future<String> uploadImage(
      String uid, String filename, Uint8List bytes) async {
    final _uploadPhotoEndpoint =
        'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/$uid/uploads';
    var uri = Uri.parse(_uploadPhotoEndpoint);
    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = uid
      ..fields['filename'] = filename
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: filename, contentType: MediaType('image', 'jpeg')));

    var res = await request.send();
    if (res.statusCode != 200) {
      throw StateError(
          'Could not upload image, ${await res.stream.bytesToString()}');
    }

    final data = Map<String, dynamic>.from(
      json.decode(await res.stream.bytesToString()),
    );

    return data['path'];
  }

  Future<void> saveCardImage(
    CardSide side,
    String uid,
    String id,
    String path,
  ) async {
    await parent.doc(uid).collection(collectionName).doc(id).set(
      <String, dynamic>{side.field: path},
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String uid, String id) {
    return parent.doc(uid).collection(collectionName).doc(id).delete();
  }

  Future<void> saveCode(String uid, String id, String number) {
    return parent.doc(uid).collection(collectionName).doc(id).set(
      {'number': number},
      SetOptions(merge: true),
    );
  }

  Future<void> saveLabel(String uid, String id, String label) {
    return parent.doc(uid).collection(collectionName).doc(id).set(
      {'label': label},
      SetOptions(merge: true),
    );
  }
}
