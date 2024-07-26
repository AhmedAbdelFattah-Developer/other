import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class IncompleteProfileScreen extends StatelessWidget {
  IncompleteProfileScreen({this.state});

  final AssetImage logo = AssetImage('assets/images/uwin_logo.png');
  final String state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFEFEF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 135.0,
            padding: EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(2.0, 2.0),
                  blurRadius: 4.0,
                )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: logo,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          SizedBox(height: 70.0),
          Text(
            state == 'disclaimer'
                ? 'Please accept the disclaimer'
                : 'To win voucher,\nplease complete your profile',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25.0),
          CupertinoButton(
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pushNamed('/edit-profile');
            },
            child: Text('Go To Profile'),
          ),
        ],
      ),
    );
  }
}
