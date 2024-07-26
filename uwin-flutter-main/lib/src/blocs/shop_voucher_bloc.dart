import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/repositories/sales_order_repository.dart';

import '../models/shop.dart';
import '../models/voucher.dart';
import '../repositories/shop_voucher_repository.dart';
import 'auth_bloc.dart';

class ShopVoucherBloc {
  final AuthBloc authBloc;
  final ShopVoucherRepository repo;
  final SalesOrderRepository soRepo;

  ShopVoucherBloc(this.authBloc, this.repo, this.soRepo);

  Stream<List<Voucher>> getVouchers(Shop shop) => repo.fetchAllGift(shop);

  Future<String> getNonce(http.Client client) async {
    final url = 'https://us-central1-uwin-201010.cloudfunctions.net' +
        '/payment/getToken';
    final res = await client.get(Uri.parse(url));

    return res.body;
  }

  SalesOrder createSalesOrder(Voucher voucher, Shop shop) {
    final so = SalesOrder(
      shop.id,
      authBloc.currentUser.id,
      shippingLabel: 'N/A',
      model: 'giftVoucher',
    );
    so.id = soRepo.createId();
    so.items.add(SalesOrderItem(
      voucher.toItem(),
      voucher.name,
      voucher.name,
      voucher.photoPath,
      1,
      voucher.amount * 100,
      0,
    ));
    so.updateTotal();

    return so;
  }

  Future<dynamic> checkout(
    http.Client client,
    Voucher voucher,
    String paymentNonce,
  ) async {
    final user = authBloc.currentUser;
    final body = json.encode({
      'name': voucher.name,
      'shopId': voucher.shopId,
      'shopName': voucher.shopName,
      'photoPath': voucher.photoPath,
      'uid': user.id,
      'token': user.token,
      'amount': voucher.amount,
      'paymentNonce': paymentNonce,
    });

    final url = 'https://us-central1-uwin-201010.cloudfunctions.net' +
        '/payment/checkout';
    final res = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return res.body;
  }
}
