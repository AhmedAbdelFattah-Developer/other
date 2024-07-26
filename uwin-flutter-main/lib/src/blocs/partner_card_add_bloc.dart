import 'package:flutter/services.dart';
import 'package:uwin_flutter/src/repositories/shop_repository.dart';

class PartnerCardAddBloc {
  final ShopRepository shopRepo;

  PartnerCardAddBloc({this.shopRepo});

  Future<String> scan() async {
    return '';
    // try {
    //   String barcode = FlutterQrReader.imgScan(path)

    //   return barcode;
    // } on PlatformException catch (e) {
    //   if (e.code == BarcodeScanner.CameraAccessDenied) {
    //     throw 'The user did not grant the camera permission!';
    //   } else {
    //     throw 'Unknown error: $e';
    //   }
    // } on FormatException {
    //   throw 'null (return using the "back"-button before scanning anything.)';
    // } catch (e) {
    //   throw 'Unknown error: $e';
    // }
  }

  dispose() {}
}
