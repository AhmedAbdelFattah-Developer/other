import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import '../repositories/shop_repository.dart';
import 'auth_bloc.dart';
import '../models/pos.dart';

class PosBloc {
  final AuthBloc authBloc;
  final ShopRepository shopRepo;
  final _pos = PublishSubject<Pos>();

  PosBloc({@required this.authBloc, @required this.shopRepo});

  Stream<Pos> get pos => _pos.stream;

  fetch(String id, String posId) async {
    try {
      final token = await authBloc.token;
      final p = await shopRepo.fetchPos(id, posId, token);
      _pos.sink.add(p);
    } catch (err) {
      print('[pos_bloc] Could not fetch pos');
      print(err);
      _pos.sink.addError('Could not fetch point of sale information');
    }
  }

  dispose() {
    _pos.close();
  }
}
