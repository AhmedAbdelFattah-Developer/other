import 'package:flutter/material.dart';

import '../forget_password_bloc.dart';
export '../forget_password_bloc.dart';

class ForgetPasswordBlocProvider extends InheritedWidget {
  final ForgetPasswordBloc bloc = ForgetPasswordBloc();

  ForgetPasswordBlocProvider({Key key, Widget child})
      : super(key: key, child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ForgetPasswordBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ForgetPasswordBlocProvider>()
        .bloc;
  }
}
