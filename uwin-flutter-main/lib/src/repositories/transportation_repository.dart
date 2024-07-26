import '../models/transportation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransportationRepository {
  static const endpoint = 'https://u-win.shop/admin/transportationList';
  final http.Client client;

  TransportationRepository(this.client);

  Future<List<Transportation>> fetchAll(String token) async {
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
        .map<Transportation>((data) => Transportation.fromApi(data))
        .toList();
  }
}
