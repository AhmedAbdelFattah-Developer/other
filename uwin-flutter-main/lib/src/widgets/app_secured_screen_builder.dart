import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/incomplete_profile_screen.dart';
import '../blocs/providers/auth_block_provider.dart';
import '../screens/login_screens.dart';

class AppSecuredScreenBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final checkIncompleteProfile;

  AppSecuredScreenBuilder({this.builder, this.checkIncompleteProfile = true});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBlocProvider.of(context);
    final loginScreen = Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          headline2: TextStyle(color: const Color(0xFFA55F10)),
        ),
        primaryColor: Colors.black,
        hintColor: Colors.white,
      ),
      child: LoginScreen(),
    );

    return StreamBuilder<String>(
      stream: authBloc.authState,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          return loginScreen;
        }

        if (!snapshot.hasData) {
          return Container(
            color: const Color(0xFFEFEFEF),
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        switch (snapshot.data) {
          case 'incompleted':
          case 'disclaimer':
          case 'completed':
            return builder(context);
          default:
            return loginScreen;
        }
      },
    );
  }
}
