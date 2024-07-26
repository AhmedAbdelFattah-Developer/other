import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';
import '../blocs/auth_bloc.dart';

const _voucherEndpoint = 'https://u-win.shop/admin/users/:id/coupons';

class CouponRepository {
  final AuthBloc authBloc;

  CouponRepository({@required this.authBloc});

  Future<List<Coupon>> fetchCoupon(String token, String userId) async {
    final client = new http.Client();
    final url = _voucherEndpoint.replaceFirst(':id', userId);

    try {
      var res = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (res.statusCode != 200) {
        throw "Could not find coupons";
      }
      final data = json.decode(utf8.decode(res.bodyBytes));

      if (res.statusCode != 200) {
        throw data;
      }

      return List<dynamic>.from(data)
          .map<Coupon>((d) => Coupon.fromApi(d))
          .where((c) => c.usedDate == 0)
          .toList();
    } finally {
      client.close();
    }
  }
}
