import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/models/mission.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/voucher.dart';

class MissionRepository {
  final http.Client client;

  MissionRepository(this.client);

  Stream<List<Mission>> findAll(String uid, String token) =>
      Stream.fromFuture(_findAll(uid, token));

  Future<List<Mission>> _findAll(String uid, String token) async {
    final endpoint = 'https://u-win.shop/admin/users/$uid/missions';
    final res = await client.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (res.statusCode != 200) {
      debugPrint("Debug Error Body: ${res.body}");
      throw StateError(
          'Could not connect to uWin server. Error code: ${res.statusCode}');
    }

    return json
        .decode(
          utf8.decode(res.bodyBytes),
        )
        .map<Mission>((data) => Mission.fromApi(data))
        .toList();
  }

  Future<List<Voucher>> fetchMissionVouchers(
    String missionId,
    String token,
  ) async {
    final endpoint =
        'https://u-win.shop/admin/v2/missions/${missionId}/vouchers';
    debugPrint("Debug Endpoint: $endpoint");
    final res = await client.get(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (res.statusCode != 200) {
      debugPrint("Debug Error Body: ${res.body}");
      throw StateError(
          'Could not connect to uWin server. Error code: ${res.statusCode}');
    }

    return json
        .decode(res.body)
        .map<Voucher>((data) => Voucher.fromApi(data))
        .toList();
  }
}
