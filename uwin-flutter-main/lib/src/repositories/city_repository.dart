import '../models/city.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityRepository {
  static const endpoint = 'https://u-win.shop/admin/cities';
  final http.Client client;

  CityRepository(this.client);

  Future<List<City>> fetchAll(String token) async {
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
        .map<City>((data) => City.fromApi(data))
        .toList();
  }
}
