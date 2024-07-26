import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class UwinBarcodeScanner {
  Future<String> scan() {
    return FlutterBarcodeScanner.scanBarcode(
      '#000000',
      'cancel',
      true,
      ScanMode.BARCODE,
    );
  }
}
