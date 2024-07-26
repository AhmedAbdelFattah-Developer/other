import 'package:flutter/cupertino.dart';

class ScreenBg extends StatelessWidget {
  final Widget child;

  const ScreenBg({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/bg.png'),
        ),
      ),
      child: child,
    );
  }
}
