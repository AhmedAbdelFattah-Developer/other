import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';

class GmsAvailable extends StatelessWidget {
  final Widget child;

  const GmsAvailable({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return child;
    }

    return FutureBuilder<bool>(
      // future: FlutterHmsGmsAvailability.isGmsAvailable,
      future: Future.value(true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return Container();
        }

        if (!snapshot.data) {
          return Container();
        }

        return child;
      },
    );
  }
}
