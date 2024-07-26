import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/voucher.dart';

import '../models/transaction.dart';
import '../blocs/auth_bloc.dart';

class TransactionRepository {
  final AuthBloc authBloc;
  final http.Client httpClient;
  final String firebaseFunctionsUrl;

  const TransactionRepository({
    @required this.authBloc,
    @required this.httpClient,
    @required this.firebaseFunctionsUrl,
  });

  Future<Map<String, VoucherCode>> record(
    String shopId,
    String userId,
    Transaction trans,
    List<String> voucherWithCodes,
  ) async {
    final codes = await lazyRecord(shopId, userId, trans);
    final codeMap = Map<String, VoucherCode>.fromIterables(
      codes.map((code) => code.code),
      codes.map((code) => code),
    );

    return codeMap;
  }

  Future<List<VoucherCode>> _fetchGiftVoucherCodes(
    String userId,
    String transId,
  ) async {
    final url =
        '$firebaseFunctionsUrl/userApi/v1/users/$userId/userApi/transactions-gift-vouchers-codes/$transId';
    debugPrint('[transaction_api_provider] URL: $url');
    final res = await httpClient.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': authBloc.currentUser.token,
    });

    if (res.statusCode != 200) {
      debugPrint('[transaction_api_provider] $url Error: ${res.body}');
      throw 'Unexpected HTTP status code when fetching gift voucher codes. Status Code ${res.statusCode}, Body: ${res.body}';
    }

    debugPrint('res.body: ${res.body}');

    final data = json.decode(utf8.decode(res.bodyBytes));

    return List<Map<String, dynamic>>.from(data)
        .map((d) => VoucherCode.fromMap(d))
        .toList();
  }

  _recordToServer(
    String token,
    String shopId,
    String userId,
    Transaction trans,
  ) async {
    final url = 'https://u-win.shop/admin/users/$userId/shops/$shopId/userShop';
    final body = json.encode(TransactionServer.fromTransaction(trans).toMap());
    print('>>>>>>>>>>>>>>>> url: $url');
    print('>>>>>>>>>>>>>>>> token: $token');
    print('>>>>>>>>>>>>>>>> body: $body');

    final res = await httpClient.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: body,
    );

    if (res.statusCode != 204) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      print('[transaction_api_provider] Error: $data');

      throw 'Could not record transaction';
    }
  }

  Future<String> _recordToFirestore(
    String shopId,
    String userId,
    Transaction trans,
  ) async {
    final url = '$firebaseFunctionsUrl/recordTransaction/v2/$userId/$shopId';
    final res = await httpClient.post(
      Uri.parse(url),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode(trans.toMap()),
    );

    if (res.statusCode != 200) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      print('[transaction_api_provider] Error: $data');

      throw 'An unexpected error has occurred';
    }

    final data = Map<String, dynamic>.from(
      json.decode(utf8.decode(res.bodyBytes)),
    );

    return data["id"];
  }

  Future<VoucherCode> _useVoucherCode(
    String uid,
    String voucherId,
    String token,
  ) async {
    final endpoint =
        '$firebaseFunctionsUrl/userApi/v1/users/:userId/vouchers/:voucherId/codes/use';
    final httpClient = http.Client();

    final res = await httpClient.post(
      Uri.parse(endpoint
          .replaceFirst(':userId', uid)
          .replaceFirst(':voucherId', voucherId)),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (res.statusCode != 200) {
      print('[transaction_api_provider] Error: ${res.body}');

      throw 'An unexpected error has occurred';
    }
    final data = json.decode(utf8.decode(res.bodyBytes));

    return VoucherCode.fromMap(data);
  }

  Future<void> wakeup() async {
    final urls = <String>[
      '$firebaseFunctionsUrl/userApi/v1/wakeup',
      '$firebaseFunctionsUrl/recordTransaction/v2/wakeup',
    ];
    final resList = await Future.wait(urls.map((url) => httpClient.post(
          Uri.parse(url),
        )));
    for (final res in resList) {
      if (res.statusCode != HttpStatus.noContent) {
        throw new StateError('Could not wake up: ${res.request.url}');
      }
    }
  }

  Future<List<VoucherCode>> lazyRecord(
      String shopId, String userId, Transaction transaction) async {
    final url =
        '$firebaseFunctionsUrl/userApi/v1/users/$userId/shops/$shopId/transactions';
    final token = authBloc.currentUser.token;

    final res = await httpClient.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(transaction.toMap()),
    );

    if (res.statusCode != 200) {
      print('[transaction_api_provider] Error: ${res.body}');

      throw 'An unexpected error has occurred';
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return List<Map<String, dynamic>>.from(data)
        .map((e) => VoucherCode.fromMap(e))
        .toList();
  }
}
