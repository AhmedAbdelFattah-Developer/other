import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/banner.dart';

class BannerRepository {
  Stream<Banner> find({String id: 'home'}) {
    return FirebaseFirestore.instance
        .collection('banners')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Banner.fromApi(doc.data()) : null);
  }
}
