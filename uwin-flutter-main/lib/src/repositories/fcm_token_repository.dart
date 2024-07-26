import 'package:cloud_firestore/cloud_firestore.dart';

const _collection = 'users';
const _subcollection = 'fcmTokens';

class FcmTokenRepository {
  Future<void> add(String userId, String token) async {
    await FirebaseFirestore.instance
        .doc('$_collection/$userId/$_subcollection/$token')
        .set({'value': token});
  }
}
