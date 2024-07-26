import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/screens/home_screen.dart';
import 'package:uwin_flutter/src/screens/services/auth_service.dart';
import 'package:uwin_flutter/src/widgets/screen_bg.dart';

class OtpSignInPinScreen extends StatefulWidget {
  static const routeName = '/otp-signin/pin';
  static const AssetImage logo = AssetImage('assets/images/uwin_logo.png');
  static const Color backgroundColor1 = Colors.black54;
  static const Color backgroundColor2 = Colors.black38;
  static const Color highlightColor = Colors.white30;
  static const Color foregroundColor = Colors.white;
  final OtpToken token;

  const OtpSignInPinScreen({Key key, @required this.token}) : super(key: key);

  @override
  State<OtpSignInPinScreen> createState() => _OtpSignInPinScreenState();
}

class _OtpSignInPinScreenState extends State<OtpSignInPinScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showActivityIndicator = false;
  String _code = "";

  Widget build(BuildContext context) {
    final brandIcon = Container(
      height: 135.0,
      width: 135.0,
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
            image: OtpSignInPinScreen.logo,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );

    return Scaffold(
      body: ScreenBg(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 75.0,
                  ),
                  brandIcon,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 40),
                    child: Text(
                      "uwin",
                      style: TextStyle(
                          color: OtpSignInPinScreen.foregroundColor,
                          fontSize: 32.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Please enter the 6 digit pin sent\nto your phone number',
                      style: TextStyle(
                          color: OtpSignInPinScreen.foregroundColor,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(40.0),
                    child: TextFieldPinAutoFill(
                      decoration: InputDecoration(
                        floatingLabelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        labelText: 'One Time Password (OTP)',
                        errorStyle: TextStyle(color: Colors.red.shade900),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.8,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      currentCode: _code,
                      onCodeChanged: (code) {
                        _code = code;
                      },
                      codeLength: 6,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    width: double.infinity,
                    child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        child: showActivityIndicator
                            ? CupertinoActivityIndicator()
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                        onPressed: showActivityIndicator
                            ? null
                            : () {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }
                                () async {
                                  try {
                                    setState(() {
                                      showActivityIndicator = true;
                                    });
                                    await Provider.of<AuthBloc>(
                                      context,
                                      listen: false,
                                    ).signInWithOtp(widget.token.token, _code);
                                    final nav = Navigator.of(context);
                                    if (nav.canPop()) {
                                      nav.pop();
                                    }
                                    nav.pushReplacementNamed(
                                        HomeScreen.routeName);
                                  } catch (err) {
                                    showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: Text('Error'),
                                            content: Text(err.toString()),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } finally {
                                    setState(() {
                                      showActivityIndicator = false;
                                    });
                                  }
                                }();
                              }),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: CupertinoButton(
                      color: Colors.white.withAlpha(200),
                      child: Text('Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                          )),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
