import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';

import '../auth_bloc.dart';
import '../shop_bloc.dart';
export '../shop_bloc.dart';

class ShopBlocProvider extends InheritedWidget {
  final AuthBloc authBloc;
  final HttpCacheManager cache;

  ShopBlocProvider({Key key, Widget child, this.authBloc, this.cache})
      : super(
          key: key,
          child: Provider<ShopBloc>(
            child: child,
            create: (_) => ShopBloc(authBloc, cache),
          ),
        );

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ShopBloc of(BuildContext context) {
    return Provider.of<ShopBloc>(context, listen: false);
  }
}
