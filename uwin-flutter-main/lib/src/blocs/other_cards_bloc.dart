import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/models/other_card.dart';
import 'package:uwin_flutter/src/repositories/other_card_repository.dart';
import 'package:uwin_flutter/src/scanner/barcode_scanner.dart';

class OtherCardsBloc {
  final AuthBloc authBloc;
  final UwinBarcodeScanner barcodeScanner;
  final OtherCardRepository otherCardRepo;
  final _nid = BehaviorSubject<OtherCard>();

  OtherCardsBloc(this.authBloc, this.otherCardRepo, this.barcodeScanner);

  init() async {
    final id = 'nid';
    final u = await authBloc.user.first;

    final c = await otherCardRepo.findOne(u.id, id);
    if (c == null) {
      _nid.add(OtherCard(uid: u.id, id: id));

      return;
    }

    _nid.add(c);
  }

  Stream<OtherCard> get nid => _nid.stream;
  Stream<List<OtherCard>> get list => authBloc.user.switchMap((u) {
        return otherCardRepo.findByUser(u.id);
      });

  Future<String> scanAndSave() async {
    String id = 'nid';
    String barcode = await barcodeScanner.scan();
    final user = await authBloc.user.first;
    _nid.add(null);
    await otherCardRepo.save(user.id, id, 'ID Card', barcode);
    init();

    return barcode;
  }

  void dispose() {
    _nid.close();
  }
}
