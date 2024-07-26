import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uwin_flutter/src/models/category.dart';

const _path = 'classifications/product/mainCategory';

class CategoryRepository {
  Future<List<Category>> fetchAll() async {
    final snap = await FirebaseFirestore.instance.collection(_path).get();

    return snap.docs.map((doc) => Category.fromMap(doc.data()));
  }
}
