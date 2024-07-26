import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/cache/http_cache_manager.dart';
import 'package:uwin_flutter/src/repositories/banner_repository.dart';

import '../auth_bloc.dart';
import '../flashsells_bloc.dart';
export '../flashsells_bloc.dart';

class FlashsellsProvider extends InheritedWidget {
  final FlashsellsBloc bloc;
  final AuthBloc authBloc;
  final HttpCacheManager cache;
  final BannerRepository bannerRepo;

  FlashsellsProvider({Key key, Widget child, @required this.authBloc, @required this.cache, @required this.bannerRepo})
      : bloc = FlashsellsBloc(authBloc, cache, bannerRepo),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static FlashsellsBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlashsellsProvider>().bloc;
  }
}
