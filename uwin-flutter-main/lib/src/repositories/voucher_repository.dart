import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voucher.dart';
import '../blocs/auth_bloc.dart';

const _voucherEndpoint =
    'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/:id/vouchers';

class VoucherRepository {
  final AuthBloc authBloc;

  VoucherRepository({@required this.authBloc});

  Future<List<Voucher>> fetchVoucher(String token, String userId) async {
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
        throw res.body;
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      return List<dynamic>.from(data)
          .map<Voucher>((d) => Voucher.fromApi(d))
          .toList();
    } finally {
      client.close();
    }
  }

  Future<List<Voucher>> fetchVoucherByShop(
    String token,
    String userId,
    String shopId,
  ) async {
    return this
        .fetchVoucher(token, userId)
        .then((vList) => vList.where((v) => v.shopId == shopId).toList());
  }
}
