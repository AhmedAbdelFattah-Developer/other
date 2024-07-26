import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/shop_voucher_bloc.dart';
import 'package:uwin_flutter/src/repositories/sales_order_repository.dart';
import 'package:uwin_flutter/src/repositories/shop_voucher_repository.dart';

import '../auth_bloc.dart';
import '../shop_voucher_bloc.dart';
export '../shop_voucher_bloc.dart';

class ShopVoucherBlocProvider extends InheritedWidget {
  final ShopVoucherBloc bloc;
  final AuthBloc authBloc;
  final ShopVoucherRepository repo;
  final SalesOrderRepository soRepo;

  ShopVoucherBlocProvider({
    Key key,
    Widget child,
    @required this.authBloc,
    @required this.repo,
    @required this.soRepo,
  })  : bloc = ShopVoucherBloc(authBloc, repo, soRepo),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ShopVoucherBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShopVoucherBlocProvider>()
        .bloc;
  }
}
