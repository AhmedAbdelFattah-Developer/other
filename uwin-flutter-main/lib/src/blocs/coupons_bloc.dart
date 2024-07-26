import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import '../models/coupon.dart';
import '../models/user.dart';
import 'auth_bloc.dart';
import 'package:http/http.dart' as http;

class CouponsBloc {
  final PublishSubject<List<Coupon>> _coupons = PublishSubject<List<Coupon>>();
  final String endpoint = 'https://u-win.shop/admin/users/{id}/coupons';
  final AuthBloc authBloc;

  CouponsBloc(this.authBloc);

  Stream<List<Coupon>> get coupons => _coupons.stream;

  void fetch() {
    authBloc.user.listen((User user) async {
      final client = http.Client();
      String url = endpoint.replaceFirst('{id}', user.id);

      try {
        final res = await client.get(Uri.parse(url), headers: {
          'Content-Type': 'application/json',
          'Authorization': user.token,
        });

        if (res.statusCode != 200) {
          _coupons.addError("Could not fetch user coupons");

          return;
        }

        final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));
        final List<Coupon> couponList = dataList
            .map(
              (data) => Coupon.fromApi(data),
            )
            .toList();
        _coupons.sink.add(couponList);
      } finally {
        client.close();
      }
    });
  }
}
