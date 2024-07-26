import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rxdart/subjects.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/repositories/transaction_repository.dart';
import '../repositories/shop_repository.dart';
import 'auth_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class ScanPartnerQrBloc {
  ScanPartnerQrBloc({
    @required this.shopRepo,
    @required this.authBloc,
    @required this.transactionRepo,
  });

  final ShopRepository shopRepo;
  final TransactionRepository transactionRepo;
  final AuthBloc authBloc;
  final _showSpinner = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get showSpinner => _showSpinner.stream;

  // Return shop ID unvalidated
  Future<String> scan(BuildContext context) async {
    try {
      bool isProd = true;
      assert(() {
        isProd = false;

        return true;
      }());
      final barcode = isProd
          ? (await FlutterBarcodeScanner.scanBarcode(
              '#000000',
              'cancel',
              true,
              ScanMode.QR,
            ))
          : '5f0d77f85f6650095d519692';
      await transactionRepo.wakeup();

      return barcode.replaceAll('|', '');
    } catch (e) {
      throw 'Unknown error: $e';
    }
  }

  Future<Shop> fetchShop(String id) async {
    _showSpinner.sink.add(true);
    final u = await authBloc.user.take(1).first;
    final shop = await shopRepo.fetch(u.token, id);
    _showSpinner.sink.add(false);

    return shop;
  }

  dispose() {
    _showSpinner.close();
  }

  Future<String> getGeolocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(Duration(seconds: 5),
              onTimeout: () => throw 'Could not find position');

      return '${position.latitude},${position.longitude}';
    } catch (err) {
      return '';
    }
  }
}
