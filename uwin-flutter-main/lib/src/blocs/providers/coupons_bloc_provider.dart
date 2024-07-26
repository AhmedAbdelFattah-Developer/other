import 'package:flutter/material.dart';

import '../auth_bloc.dart';
import '../coupons_bloc.dart';
export '../coupons_bloc.dart';

class CouponsBlocProvider extends InheritedWidget {
  final CouponsBloc bloc;
  final AuthBloc authBloc;

  CouponsBlocProvider({Key key, Widget child, this.authBloc})
      : bloc = CouponsBloc(authBloc),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static CouponsBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CouponsBlocProvider>()
        .bloc;
  }
}
