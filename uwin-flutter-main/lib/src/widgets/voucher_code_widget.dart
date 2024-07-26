import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VoucherCodeWidget extends StatelessWidget {
  final String code;

  VoucherCodeWidget(this.code, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: QrImageView(
            data: code,
            version: QrVersions.auto,
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
