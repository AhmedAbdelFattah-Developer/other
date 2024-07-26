import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/occupation.dart';

class OccupationRepository {
  static const endpoint = 'https://u-win.shop/admin/occupationList';
  final http.Client client;

  OccupationRepository(this.client);

  Future<List<Occupation>> fetchAll(String token) async {
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
        .map<Occupation>((data) => Occupation.fromApi(data))
        .toList();
  }
}
