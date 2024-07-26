import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/win_credits_content.dart';

class WinCreditsRepository {
  Stream<WinCreditsContent> get winCredits =>
      FirebaseFirestore.instance.doc('win-credits/win-credits').snapshots().map(
        (doc) {
          if (!doc.exists) {
            throw 'Firebase document win-credits/win-credits not found';
          }

          return WinCreditsContent.fromMap(doc.data());
        },
      );
}
