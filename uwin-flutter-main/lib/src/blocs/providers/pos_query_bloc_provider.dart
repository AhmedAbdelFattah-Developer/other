import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';
import 'package:uwin_flutter/src/repositories/shop_type_repository.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';

import '../pos_query_bloc.dart';
export '../pos_query_bloc.dart';

class PosQueryBlocProvider extends InheritedWidget {
  final PosQueryBloc bloc;
  final AuthBloc authBloc;
  final HttpCacheManager cache;
  final VoucherRepository voucherRepo;
  final ShopTypeRepository shopTypeRepo;

  PosQueryBlocProvider({
    Key key,
    @required Widget child,
    @required this.authBloc,
    @required this.cache,
    @required this.voucherRepo,
    @required this.shopTypeRepo,
  })  : bloc = PosQueryBloc(authBloc, cache, voucherRepo, shopTypeRepo),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static PosQueryBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PosQueryBlocProvider>()
        .bloc;
  }
}
