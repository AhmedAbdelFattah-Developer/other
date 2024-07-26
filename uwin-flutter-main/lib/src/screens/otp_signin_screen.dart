import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/screens/otp_sigin_pin_screen.dart';
import 'package:uwin_flutter/src/widgets/screen_bg.dart';

class OtpSignInScreen extends StatefulWidget {
  static const routeName = '/otp-signin';
  static const AssetImage logo = AssetImage('assets/images/uwin_logo.png');
  static const Color backgroundColor1 = Colors.black54;
  static const Color backgroundColor2 = Colors.black38;
  static const Color highlightColor = Colors.white30;
  static const Color foregroundColor = Colors.white;

  @override
  State<OtpSignInScreen> createState() => _OtpSignInScreenState();
}

class _OtpSignInScreenState extends State<OtpSignInScreen> {
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showActivityIndicator = false;

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
            image: OtpSignInScreen.logo,
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
                          color: OtpSignInScreen.foregroundColor,
                          fontSize: 32.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Please enter your phone number',
                      style: TextStyle(
                          color: OtpSignInScreen.foregroundColor,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(40.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 10.0, right: 00.0),
                          child: Icon(
                            CupertinoIcons.phone_fill,
                            color: OtpSignInScreen.foregroundColor,
                          ),
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              floatingLabelStyle: TextStyle(
                                color: OtpSignInScreen.foregroundColor,
                              ),
                              labelText: 'Phone Number',
                              errorStyle: TextStyle(color: Colors.red.shade900),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: OtpSignInScreen.foregroundColor,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: OtpSignInScreen.foregroundColor,
                                  width: 0.8,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                'Request OTP',
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
                                    // await SmsAutoFill().listenForCode();
                                    final token = await Provider.of<AuthBloc>(
                                      context,
                                      listen: false,
                                    ).requestOtp(_phoneNumberController.text);
                                    Navigator.of(context).pushReplacementNamed(
                                      OtpSignInPinScreen.routeName,
                                      arguments: <String, dynamic>{
                                        'token': token
                                      },
                                    );
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
