import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';

import '../auth_bloc.dart';
import '../register_bloc.dart';
export '../register_bloc.dart';

class RegisterBlocProvider extends InheritedWidget {
  final RegisterBloc bloc;
  final AuthBloc authBloc;
  final AuthService authService;

  RegisterBlocProvider({
    Key key,
    Widget child,
    @required this.authBloc,
    @required this.authService,
  })  : bloc = RegisterBloc(authBloc, authService),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static RegisterBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RegisterBlocProvider>()
        .bloc;
  }
}
