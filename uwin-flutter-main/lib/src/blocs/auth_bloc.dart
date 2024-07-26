import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uwin_flutter/src/models/profile.dart';
import 'package:uwin_flutter/src/models/user.dart' as model;
import 'package:uwin_flutter/src/repositories/disclaimer_repository.dart';
import 'package:uwin_flutter/src/repositories/fcm_token_repository.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';

class UserProfile {
  final model.User user;
  final Profile profile;

  UserProfile({this.user, this.profile});
}

class AuthBloc {
  bool isIos;
  AuthBloc({
    @required this.userRepo,
    @required this.authService,
  }) : isIos = Platform.isIOS;
  

  final AuthService authService;
  final UserRepository userRepo;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _googleSignIn = GoogleSignIn(scopes: <String>['email']);
  final disclaimerRespository = DisclaimerRespository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final fcmTokenRepo = FcmTokenRepository();

  final BehaviorSubject<model.User> _user = BehaviorSubject<model.User>();
  final BehaviorSubject<Profile> _profile = BehaviorSubject<Profile>();
  final BehaviorSubject<String> _authState = BehaviorSubject<String>();
  final pwdFieldController = TextEditingController();
  final emailFieldController = TextEditingController();

  Stream<model.User> get user => _user.stream;
  Stream<Profile> get profile => _profile.stream;
  Stream<String> get authState => _authState.stream;

  Profile get currentProfile => _profile.value;
  model.User get currentUser => _user.value;

  Stream<UserProfile> get userProfile =>
      Rx.combineLatest2<model.User, Profile, UserProfile>(
        user,
        profile,
        (model.User u, Profile p) {
          return UserProfile(user: u, profile: p);
        },
      );

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await FirebaseAuth.instance.signOut();
    _user.sink.addError('Logout');
    _profile.sink.addError('Logout');
    _authState.sink.addError('logout');
    if (_googleSignIn != null) {
      _googleSignIn.signOut();
    }
  }

  Future<String> get token async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw StateError('User not authenticated.');
    }

    return token;
  }

  autoAuthenticate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    debugPrint('>>>>>>>>>>>>>> UserID: $id');

    if (id != null) {
      print('[auth_bloc] autoAuthenticate $id');
      final user = model.User(
        id: id,
        name: prefs.getString('name'),
        role: prefs.getString('role'),
        token: prefs.getString('token'),
        success: true,
      );

      final client = http.Client();
      try {
        await _firebaseLogin(client, user);
        final profile = await _fetchProfile(client, user);
        await _initFCM(user);
        addAuthToSinks(user, profile);
      } catch (err) {
        _user.sink.addError('Logout');
        _profile.sink.addError('Logout');
        _authState.sink.addError('logout');
      } finally {
        client.close();
      }
    } else {
      _user.sink.addError('Logout');
      _profile.sink.addError('Logout');
      _authState.sink.addError('logout');
    }
  }

  addAuthToSinks(model.User user, Profile profile) async {
    _user.sink.add(user);
    _profile.sink.add(profile);
    updateState(profile);
  }

  updateState(Profile profile) async {
    if (profile.profileCompleted) {
      try {
        if (await disclaimerRespository.accepted) {
          _authState.sink.add('completed');
        } else {
          _authState.sink.add('disclaimer');
        }
      } catch (err) {
        debugPrint('[AuthBloc.addAuthToSinks] Could not get disclaimer state');
        debugPrint(err);
        _authState.sink.add('incompleted');
      }
    } else {
      _authState.sink.add('incompleted');
    }
  }

  Future<void> updateProfile() async {
    // _profile.add(null);
    final client = new http.Client();
    try {
      final profile = await _fetchProfile(client, _user.value);
      _profile.add(profile);
      updateState(profile);
    } finally {
      client.close();
    }
  }

  Future<void> googleSignIn() async {
    _authState.sink.add('pending');
    var result, googleKey;

    try {
      result = await _googleSignIn.signIn();
    } catch (err) {
      _user.addError("Failed to login with Google");
      _authState.sink.addError('Failed to login with Google');
      debugPrint('Could not sign in using google 1: $err');

      return;
    }

    if (result == null) {
      _user.addError("Failed to login with Google");
      _authState.sink.addError('Failed to login with Google');

      return;
    }

    try {
      googleKey = await result.authentication;
      googleKey.idToken.split('.').forEach((part) => debugPrint(part));
    } catch (err) {
      _user.addError("Failed to login with Google");
      _authState.sink.addError('err1: $err');
      debugPrint('Could not sign in using google 2.\n$err');

      return;
    }

    final client = new http.Client();
    final String url = Platform.isIOS
        ? 'https://u-win.shop/ios/authUser'
        : 'https://u-win.shop/authUser';
    try {
      var res = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'id': result.id,
            'sm': 'GOOGLE',
            'smToken': googleKey.idToken,
          },
        ),
      );

      if (res.statusCode != 200) {
        _user.addError("Failed to login with Google");
        _authState.sink.addError('Server error. Code ${res.statusCode}');
        debugPrint(
          '[auth_bloc] Sign in error on uwin server with google credentials. Status code: ${res.statusCode}',
        );
        debugPrint(res.body);
        return;
      } else {
        debugPrint('[auth_bloc] Google Sign in body');
        debugPrint(res.body);
      }

      final userData = model.User.fromMap(
        json.decode(utf8.decode(res.bodyBytes)),
      );
      await doLogin(client, userData);
      await FirebaseAnalytics.instance.logLogin(loginMethod: 'Google');
    } finally {
      client.close();
    }
  }

  Future<void> facebookSignIn() async {
    debugPrint('[auth_bloc] facebookSignIn');
    _authState.sink.add('pending');
    final LoginResult result = await FacebookAuth.instance
        .login(); // by default we request the email and the public profile
// or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      final client = new http.Client();
      const String url = 'https://u-win.shop/authUser';

      try {
        var res = await client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'id': result.accessToken.userId,
              'sm': 'FACEBOOK',
              'smToken': result.accessToken.token
            },
          ),
        );

        if (res.statusCode != 200) {
          final err = getErrorMessage(res.body);
          debugPrint('res.body: $err');

          _user.addError("Facebook sign in error, $err");
          _authState.sink.addError('Facebook sign in error, $err');
          return;
        }

        final userData = model.User.fromMap(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        await doLogin(client, userData);
        await FirebaseAnalytics.instance.logLogin(loginMethod: 'Facebook');
      } finally {
        client.close();
      }
    } else {
      _user.addError('Facebook Sign In Error');
      _authState.sink.addError('Facebook Sign In Error, ${result.message}');
      debugPrint('Could not sign in using Facebook.\n.${result.message}');
    }
  }

  Future<void> authenticate(String email, String password) async {
    _authState.sink.add('pending');
    final client = new http.Client();
    const String url = 'https://u-win.shop/authUser';

    try {
      var res = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': email?.trim(),
            'pwd': sha1.convert(utf8.encode(password)).toString(),
          },
        ),
      );

      if (res.statusCode == 401 || res.statusCode == 400) {
        _user.addError("Wrong email or password");
        _authState.sink.addError('Wrong email or password');
        return;
      }

      if (res.statusCode != 200) {
        _user.addError("login failed, status ${res.statusCode}, ${res.body}");
        _authState.sink
            .addError('login failed, status ${res.statusCode}, ${res.body}');
        return;
      }

      final userData = model.User.fromMap(
        json.decode(utf8.decode(res.bodyBytes)),
      );
      await doLogin(client, userData);
      await FirebaseAnalytics.instance.logLogin(loginMethod: 'Password');
    } finally {
      client.close();
    }
  }

  Future<Profile> _fetchProfile(http.Client client, model.User user) async {
    final profiles = await Future.wait([
      _fetchProfileServer(client, user),
      if (isIos) _fetchProfileFirestore(user),
    ]);

    if (profiles.length == 1 || profiles[1] == null) {
      return profiles[0];
    }

    return Profile.combine(live: profiles[0], cache: profiles[1]);
  }

  Future<Profile> _fetchProfileFirestore(model.User user) async {
    return userRepo.fetchCacheProfile(user.id);
  }

  Future<Profile> _fetchProfileServer(
      http.Client client, model.User user) async {
    final url = 'https://u-win.shop/admin/users/${user.id}';
    final res = await client.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': user.token,
    });

    if (res.statusCode != 200) {
      _profile.addError("Could not fetch user profile");
      throw new Exception('Could not fetch user profile');
    }

    final Profile profile = Profile.fromApi(
      json.decode(
        utf8.decode(res.bodyBytes),
      ),
    );

    return profile;
  }

  Future<void> doLogin(Client client, model.User user) async {
    debugPrint('[auth_bloc] uid ${user.id}');
    debugPrint('[auth_bloc] token ${user.token}');

    await _firebaseLogin(client, user);
    debugPrint('[auth_bloc] firebase login done');

    final profile = await _fetchProfile(client, user);
    debugPrint('[auth_bloc] fetch profile done');

    // Save User Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('role', user.role ?? '');
    await prefs.setString('name', user.name);
    await prefs.setString('id', user.id);
    debugPrint('[auth_bloc] save profile to shared prefs done');

    await registerUserExt(profile.email);
    debugPrint('[auth_bloc] register user ext done');

    await _initFCM(user);
    addAuthToSinks(user, profile);
    debugPrint('[auth_bloc] add user to sink done');

    FirebaseAnalytics.instance.setUserId(id: user.id);
  }

  Future<void> _initFCM(model.User user) async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[auth_bloc] User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('[auth_bloc] User granted provisional permission');
    } else {
      debugPrint('[auth_bloc] User declined or has not accepted permission');
    }
    _firebaseMessaging
        .subscribeToTopic('news')
        .then((value) => debugPrint('Register news topic'));
    _firebaseMessaging.getToken().then((token) async {
      assert(token != null);
      try {
        debugPrint('[auth_bloc] user.id ${user.id}');
        debugPrint('[auth_bloc] user.token ${user.token}');
        debugPrint('[auth_bloc] fcm token $token');
        await fcmTokenRepo.add(user.id, token);
      } catch (err) {
        debugPrint('[auth_bloc] Could not register device to FCM');
        debugPrint('[auth_bloc] $err');
      }
    });
  }

  Future<User> get firebaseUser =>
      Future.value(FirebaseAuth.instance.currentUser);

  Future<void> _firebaseLogin(http.Client client, model.User user) async {
    final u = await firebaseUser;
    if (u != null) {
      return;
    }

    debugPrint('[auth_bloc] _firebaseLogin called: user: ${user.name}');

    final url = 'https://us-central1-uwin-201010.cloudfunctions.net/auth';
    final res = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'uid': user.id,
          'token': user.token,
        },
      ),
    );

    if (res.statusCode != 200) {
      debugPrint(res.body);
      throw StateError(
        "Could not authenticate firebase user with custom token",
      );
    }

    final authData = json.decode(utf8.decode(res.bodyBytes));

    await _auth.signInWithCustomToken(authData['token']);
  }

  Future<void> registerUserExt(String email) async {
    final ref = FirebaseFirestore.instance.doc('userExt/$email');
    final doc = await ref.get();

    if (doc.data != null) {
      return;
    }

    FirebaseFirestore.instance.doc('userExt/$email').set(<String, dynamic>{
      'email': email,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> signInWithApple({
    List<AppleIDAuthorizationScopes> scopes = const [
      AppleIDAuthorizationScopes.email
    ],
  }) async {
    _authState.sink.add('pending');
    try {
      // 1. perform the sign-in request
      final appleIdCredential =
          await SignInWithApple.getAppleIDCredential(scopes: scopes);
      // 2. check the result
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
      final authResult = await _auth.signInWithCredential(credential);
      final firebaseUser = authResult.user;

      final email = getAppleEmail(
        appleIdCredential.email,
        firebaseUser.uid,
      );

      final token = await firebaseUser.getIdToken();

      await _doSignInWithApple(firebaseUser.uid, email, token);
    } catch (err) {
      if (err is Error) {
        debugPrint(err.stackTrace.toString());
      } else {
        debugPrint("[auth_bloc] err: $err");
      }
      _user.addError("Apple Sign In Error: $err");
      _authState.addError("Unable to sign in with apple: $err");
    }
  }

  dispose() {
    _user.close();
    _profile.close();
    _authState.close();
  }

  _doSignInWithApple(String uid, String email, String token) async {
    final client = new http.Client();
    try {
      final url =
          'https://us-central1-uwin-201010.cloudfunctions.net/auth/signin/apple';
      final res = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'id': uid,
            'email': email,
            'token': token,
          },
        ),
      );

      if (res.statusCode != 200) {
        throw 'apple sign auth error on cloud function, ${res.body}';
      }

      final userData = model.User.fromMap(
        json.decode(utf8.decode(res.bodyBytes)),
      );
      await doLogin(client, userData);
      await FirebaseAnalytics.instance.logLogin(loginMethod: 'Apple');

      return res;
    } finally {
      client.close();
    }
  }

  String getAppleEmail(String email, String firebaseId) {
    if (email == null || email.isEmpty) {
      return '$firebaseId@appleuser.uwin.mu';
    }

    return email;
  }

  Future<void> signInWithOtp(String token, String code) async {
    final user = await authService.signInWithOtp(token, code);
    final client = http.Client();
    try {
      await doLogin(client, user);
    } finally {
      client.close();
    }
  }

  Future<OtpToken> requestOtp(String phone) {
    return authService.requestOtp(phone);
  }
}

String getErrorMessage(String resBody) {
  if (resBody == null) {
    return 'empty response body';
  }

  final res = json.decode(resBody);
  if (res != null && res['message'] != null) {
    return res['message'];
  }

  return resBody;
}
