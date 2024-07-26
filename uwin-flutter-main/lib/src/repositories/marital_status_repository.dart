import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/marital_status.dart';

class MaritalStatusRepository {
  static const endpoint = 'https://u-win.shop/admin/marritalStatusList';
  final http.Client client;

  MaritalStatusRepository(this.client);

  Future<List<MaritalStatus>> fetchAll(String token) async {
    final res = await client.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (res.statusCode != 200) {
      throw StateError(
          'Could not connect to uWin server. Error code: ${res.statusCode}');
    }

    return json
        .decode(
          utf8.decode(res.bodyBytes),
        )
        .map<MaritalStatus>((data) => MaritalStatus.fromApi(data))
        .toList();
  }
}
