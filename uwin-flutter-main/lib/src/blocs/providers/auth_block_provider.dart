import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';

import '../auth_bloc.dart';
export '../auth_bloc.dart';

class AuthBlocProvider extends InheritedWidget {
  final AuthBloc bloc;
  final UserRepository userRepo;
  final AuthService authService;

  AuthBlocProvider({
    Key key,
    Widget child,
    @required this.userRepo,
    @required this.authService,
    AuthBloc defaultBloc,
  })  : bloc = defaultBloc ??
            AuthBloc(
              userRepo: userRepo,
              authService: authService,
            ),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthBlocProvider>().bloc;
  }
}
