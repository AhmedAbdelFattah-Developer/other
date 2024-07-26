import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/user.dart';

class OtpToken {
  final String token;
  final int expires;

  OtpToken({this.token, this.expires});

  factory OtpToken.fromMap(Map<String, dynamic> map) {
    return OtpToken(token: map['token'], expires: map['expires']);
  }
}

class AuthService {
  final http.Client client;
  final String server;

  AuthService(this.client, this.server);

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String referral,
  ) async {
    const String url = 'https://u-win.shop/v2/auth/register';

    var res = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'email': email,
          'pwd': password,
          'userType': referral,
        },
      ),
    );

    if (res.statusCode != 200) {
      if (res.statusCode == 400) {
        final resErr = json.decode(
          utf8.decode(res.bodyBytes),
        ) as Map<String, dynamic>;

        throw StateError(resErr['message']);
      }
      throw StateError('Server erro. Code: ${res.statusCode}');
    }

    final userData = json.decode(utf8.decode(res.bodyBytes));

    return userData;
  }

  Future<void> postRegister(Map<String, dynamic> userData) async {
    final url =
        'https://u-win.shop/admin/users/${userData["id"]}/postRegisterUser';
    await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  Future<OtpToken> requestOtp(String phone) async {
    final response = await client.post(
      Uri.parse('$server/auth/otp/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error requesting OTP, err: ${response.body}');
    }

    return OtpToken.fromMap(jsonDecode(response.body));
  }

  Future<User> signInWithOtp(String token, String code) async {
    final res = await client.post(
      Uri.parse('$server/auth/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'code': code}),
    );

    if (res.statusCode != 200) {
      throw Exception('Error verifying OTP, err: ${res.body}');
    }

    return User.fromMap(jsonDecode(res.body));
  }
}
