import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/models/user.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';
import '../blocs/providers/auth_block_provider.dart';

class RegisterBloc {
  final AuthBloc authBloc;
  final emailValid = RegExp(
    r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""",
  );
  final _formErrors = PublishSubject<StateError>();
  final _showSpinner = PublishSubject<bool>();
  final _email = BehaviorSubject<String>();
  final _confirmEmail = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _referralCode = BehaviorSubject<String>();
  final _terms = BehaviorSubject<bool>.seeded(false);
  final AuthService _authService;

  RegisterBloc(this.authBloc, this._authService);

  void changeEmail(String value) => _email.sink.add(value);
  void changeConfirmEmail(String value) => _confirmEmail.add(value);
  void changePassword(String value) => _password.sink.add(value);
  void changeReferralCode(String value) => _referralCode.sink.add(value);

  Stream<StateError> get formErrors => _formErrors.stream;

  Stream<bool> get showSpinner => _showSpinner.stream;

  Stream<String> get email => _email.stream.transform(
        StreamTransformer.fromHandlers(
          handleData: (email, sink) {
            if (!emailValid.hasMatch(email)) {
              sink.addError(StateError('Invalid Email'));

              return;
            }

            sink.add(email);
          },
        ),
      );

  Stream<String> get confirmEmail => Rx.combineLatest2(
        email,
        _confirmEmail.stream,
        (email, confirmEmail) => <String>[email, confirmEmail],
      ).transform(
        StreamTransformer.fromHandlers(
          handleError: (obj, stack, sink) {},
          handleData: (emails, sink) {
            if (emails[0] != emails[1]) {
              sink.addError(
                StateError('Does not match email'),
              );

              return;
            }

            sink.add(emails[1]);
          },
        ),
      );

  Stream<String> get password => _password.stream.transform(
        StreamTransformer.fromHandlers(
          handleData: (pwd, sink) {
            if (pwd == null || pwd.length == 0) {
              sink.addError(StateError('Password is required'));

              return;
            }

            sink.add(pwd);
          },
        ),
      );

  Stream<String> get referralCode => _referralCode.stream;

  Stream<bool> get terms => _terms.stream;

  void setTerms(bool value) {
    if (!value) {
      _terms.addError(
          'Please indicate that you have read and agree to the Terms and Conditions');

      return;
    }
    _terms.add(value);
  }

  Future<void> registerUserExt(String email) {
    return FirebaseFirestore.instance
        .doc('userExt/$email')
        .set(<String, dynamic>{
      'email': email,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<bool> register(String email, String password, String referral) async {
    if (_terms.value != true) {
      setTerms(false);

      return false;
    }

    _showSpinner.add(true);
    final client = new http.Client();
    try {
      final userData = await _authService.register(email, password, referral);
      await _authService.postRegister(userData);
      await authBloc.doLogin(client, User.fromMap(userData));

      return true;
    } catch (er) {
      _formErrors.add(er);
    } finally {
      _showSpinner.add(false);
      client.close();
    }

    return false;
  }

  dispose() {
    _formErrors.close();
    _email.close();
    _confirmEmail.close();
    _password.close();
    _showSpinner.close();
    _terms.close();
  }
}
