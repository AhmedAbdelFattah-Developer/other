import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/blocs/my_wins_bloc.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';

export '../my_wins_bloc.dart';

class MyWinsBlocProvider extends InheritedWidget {
  final MyWinsBloc bloc;
  final AuthBloc authBloc;
  final VoucherRepository voucherRepo;
  final GiftVoucherRepository giftVoucherRepo;

  MyWinsBlocProvider({
    Key key,
    Widget child,
    @required this.authBloc,
    @required this.voucherRepo,
    @required this.giftVoucherRepo,
  })  : bloc = MyWinsBloc(authBloc, voucherRepo, giftVoucherRepo),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MyWinsBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MyWinsBlocProvider>()
        .bloc;
  }
}
