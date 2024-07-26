import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/repositories/other_card_repository.dart';

class AddOtherCardBloc {
  final OtherCardRepository repo;
  final AuthBloc authBloc;

  AddOtherCardBloc(this.repo, this.authBloc);

  Future<String> scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
        '#000000', 'Cancel', true, ScanMode.BARCODE);
  }

  Future<void> save(String label, String code) async {
    final uid = authBloc.currentUser.id;
    final id = repo.createId(uid);
    await repo.save(uid, id, label, code);
  }

  void dispose() {}
}
