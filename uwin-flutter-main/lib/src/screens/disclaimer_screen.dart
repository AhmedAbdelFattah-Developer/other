import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DisclaimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Privacy Policy'),
      ),
      child: WebView(
        initialUrl: "https://u-win.shop/doc/PrivacyPolicy.htm",
      ),
    );
  }
}
