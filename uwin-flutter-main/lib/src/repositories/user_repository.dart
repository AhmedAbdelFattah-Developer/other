import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/profile.dart';
import 'dart:convert';

import '../models/education_level.dart';
import '../models/gender.dart';
import '../models/marital_status.dart';
import '../models/occupation.dart';
import '../models/transportation.dart';
import '../models/transaction_user.dart';

class UserRepository {
  static const endpoint =
      'https://u-win.shop/admin/users/5d01ce355f665021f7aeb679';
  final http.Client client;

  UserRepository(this.client);

  save(
    String token,
    String userId,
    String firstName,
    String lasttName,
    String email,
    int dob,
    String phone,
    String cityId,
    String cityName,
    Gender gender,
    Occupation occupation,
    MaritalStatus maritalStatus,
    Transportation transportation,
    EducationLevel educationLevel,
  ) async {
    final profile = Profile(
      id: userId,
      fName: firstName,
      lName: lasttName,
      email: email,
      dateOfBirth: dob,
      mobile: phone,
      cityId: cityId,
      cityName: cityName,
      genderId: gender.id,
      genderLabel: gender.label,
      occupationId: occupation.id,
      occupationLabel: occupation.label,
      maritalStatusId: maritalStatus.id,
      maritalStatusLabel: maritalStatus.label,
      transportationId: transportation.id,
      transportationLabel: transportation.label,
      educationId: educationLevel.id,
      educationLabel: educationLevel.label,
    );

    var server = 'https://us-central1-uwin-201010.cloudfunctions.net';
    // assert(() {
    //   server = 'http://localhost:5000/uwin-201010/us-central1';
    //   return true;
    // }());
    final url = '$server/restApi/v1/users/${profile.id}';
    final res = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(profile.toMap()),
    );

    if (res.statusCode != 204) {
      print('[user_repository] Error: ${res.body}');
      throw 'Could not update profile';
    }
  }

  Future<TransactionUser> fetch(String token, String id) async {
    final client = http.Client();
    try {
      final url = 'https://u-win.shop/admin/users/$id';
      final res = await client.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });
      final data = json.decode(utf8.decode(res.bodyBytes));

      if (res.statusCode != 200) {
        throw data;
      }

      return TransactionUser.fromMap(data);
    } finally {
      client.close();
    }
  }

  Future<Profile> fetchProfile(String userId, String token) async {
    final url = 'https://u-win.shop/admin/users/$userId';
    final res = await client.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    });

    if (res.statusCode != 200) {
      print(
        '[user_repository] Server return code ${res.statusCode} when fetch profile data',
      );
      throw "Could not fetch user profile";
    }

    return Profile.fromApi(json.decode(utf8.decode(res.bodyBytes)));
  }

  Future<Profile> fetchCacheProfile(String userId) {
    return FirebaseFirestore.instance
        .doc('profiles/$userId')
        .get()
        .then((doc) => doc.data() == null ? null : Profile.fromMap(doc.data()));
  }

  Future<void> deleteAccount(String uid, String token) async {
    final url = 'https://uwinapi.dev.cloudns.cl/v2/users/$uid/close-account';
    final res = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 204) {
      throw 'delete account error, status code: ${res.statusCode}';
    }

    final snap = await FirebaseFirestore.instance
        .collection('appleUsers')
        .where('uid', isEqualTo: uid)
        .get();

    if (snap.docs.length > 0) {
      for (var doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  Stream<String> getReferalCode(String uid, String token) {
    final url = 'https://u-win.shop/admin/users/$uid/referral-code';
    return client
        .get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .asStream()
        .map(
          (res) {
            if (res.statusCode != 200) {
              throw 'get referal code error, status code: ${res.statusCode}';
            }

            return json.decode(utf8.decode(res.bodyBytes))['code'];
          },
        );
  }

  Stream<int> getInvitedCount(String uid, String token) {
    final url = 'https://u-win.shop/admin/users/$uid/invited-users';
    return client
        .get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .asStream()
        .map(
          (res) {
            if (res.statusCode != 200) {
              throw 'get invited users error, status code: ${res.statusCode}';
            }

            return json.decode(utf8.decode(res.bodyBytes))['count'];
          },
        );
  }
}
