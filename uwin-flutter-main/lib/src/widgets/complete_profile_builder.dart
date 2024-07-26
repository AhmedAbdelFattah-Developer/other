import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/screens/incomplete_profile_screen.dart';

class CompleteProfileBuilder extends StatelessWidget {
  final FutureOr Function(BuildContext) builder;

  const CompleteProfileBuilder({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = AuthBlocProvider.of(context);
    return StreamBuilder<String>(
      stream: bloc.authState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CupertinoPageScaffold(
            child: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return CupertinoPageScaffold(child: Container());
        }

        if (snapshot.data != 'completed') {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: IncompleteProfileScreen(),
          );
        }

        return builder(context);
      },
    );
  }
}
