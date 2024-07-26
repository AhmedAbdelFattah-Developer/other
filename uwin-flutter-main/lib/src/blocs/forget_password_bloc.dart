import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class ForgetPasswordState {
  final String label;
  const ForgetPasswordState(this.label);
}

class ForgetPasswordStates {
  static const pending = ForgetPasswordState('pending');
  static const completed = ForgetPasswordState('completed');
  static const failed = ForgetPasswordState('failed');
}

class ForgetPasswordBloc {
  static const endpoint = 'https://u-win.shop/requestPassword';

  final emailCtrl = TextEditingController();
  final PublishSubject<ForgetPasswordState> _state =
      PublishSubject<ForgetPasswordState>();

  Stream<ForgetPasswordState> get state => _state.stream;

  Future<void> requestPassword() async {
    _state.sink.add(ForgetPasswordStates.pending);

    final client = new http.Client();
    try {
      var res = await client.put(Uri.parse(endpoint), body: emailCtrl.text);

      if (res.statusCode != 204) {
        _state.sink.add(ForgetPasswordStates.failed);

        return;
      }

      _state.sink.add(ForgetPasswordStates.completed);
    } finally {
      client.close();
    }
  }

  dispose() {
    _state.close();
  }
}
