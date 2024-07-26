import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/gender.dart';

class GenderRepository {
  static const endpoint = 'https://u-win.shop/admin/genderList';
  final http.Client client;

  GenderRepository(this.client);

  Future<List<Gender>> fetchAll(String token) async {
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
        .map<Gender>((data) => Gender.fromApi(data))
        .toList();
  }
}
