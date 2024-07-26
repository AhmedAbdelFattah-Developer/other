import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uwin_flutter/src/models/shipping_details.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';
import '../models/sales_order.dart';

const _ref = 'shopSalesOrders';

class SalesOrderRepository {
  SalesOrderRepository(this.userRepo);

  final UserRepository userRepo;

  String createId() {
    return FirebaseFirestore.instance.collection(_ref).doc().id;
  }

  Stream<SalesOrder> fetch(String id) {
    return FirebaseFirestore.instance
        .doc('$_ref/$id')
        .snapshots()
        .map((doc) => SalesOrder.fromMap(doc.data()));
  }

  Future<SalesOrder> save(SalesOrder so) async {
    final db = FirebaseFirestore.instance;
    so.id = db.collection(_ref).doc().id;
    final data = json.encode(so.toMap);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('$_ref${so.shopId}', data);

    return so;
  }

  Future<void> placeOrder(SalesOrder so) {
    // so.pruneItems();

    return FirebaseFirestore.instance.doc('$_ref/${so.id}').set(so.toMap);
  }

  Future<void> saveLastShippingDetails(
      String userId, ShippingDetails sd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shipping_details_$userId', json.encode(sd.toMap));
  }

  Future<ShippingDetails> getLastShippingDetails(
    String userId,
    String token,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('shipping_details_$userId');
    if (data == null) {
      final profile = await userRepo.fetchProfile(userId, token);
      return ShippingDetails(
        city: profile.cityName,
        email: profile.email,
        firstName: profile.fName,
        lastName: profile.lName,
        phone: profile.mobile,
        postCode: '',
        street: '',
      );
    }

    return ShippingDetails.fromMap(json.decode(data));
  }
}
