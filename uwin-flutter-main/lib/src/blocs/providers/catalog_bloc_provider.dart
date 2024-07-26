import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/repositories/product_item_repository.dart';

import '../auth_bloc.dart';
import '../catalog_bloc.dart';
export '../catalog_bloc.dart';

class CatalogBlocProvider extends InheritedWidget {
  final CatalogBloc bloc;
  final AuthBloc authBloc;
  final ProductItemRepository productItemRepo;

  CatalogBlocProvider(
      {Key key, Widget child, this.authBloc, this.productItemRepo})
      : bloc = CatalogBloc(authBloc, productItemRepo),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static CatalogBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CatalogBlocProvider>().bloc;
  }
}
