import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/main.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/widgets/GmsAvailable.dart';
import 'package:uwin_flutter/src/widgets/screen_bg.dart';

import 'otp_signin_screen.dart';

const _linkColor = Color(0xCCFFFFFF);

class LoginScreen extends StatelessWidget {
  final Color backgroundColor1 = Colors.black54;
  final Color backgroundColor2 = Colors.black38;
  final Color highlightColor = Colors.white30;
  final Color foregroundColor = Colors.white;
  final AssetImage logo = AssetImage('assets/images/uwin_logo.png');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = AuthBlocProvider.of(context);

    final forgotPwdBtn = TextButton(
      onPressed: () => Navigator.of(context).pushNamed(
        '/forgot-password',
        arguments: <String, dynamic>{'email': bloc.emailFieldController.text},
      ),
      child: Text(
        "Forgot your password?",
        style: TextStyle(
          color: _linkColor,
          fontSize: 14.0,
          decoration: TextDecoration.underline,
        ),
      ),
    );

    final loginBtn = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        top: 10.0,
        bottom: 10.0,
      ),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<String>(
                stream: bloc.authState,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<String> snapshot,
                ) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return CupertinoButton(
                      key: Key('loginBtn'),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      color: theme.hintColor,
                      onPressed: () {
                        bloc.authenticate(
                          bloc.emailFieldController.text,
                          bloc.pwdFieldController.text,
                        );
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(color: const Color(0xFFFE9015)),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: CupertinoActivityIndicator(),
                  );
                }),
          ),
        ],
      ),
    );

    final appleSignInBtn = StreamBuilder<String>(
      stream: bloc.authState,
      builder: (
        BuildContext context,
        AsyncSnapshot<String> snapshot,
      ) {
        if (!snapshot.hasData || snapshot.hasError) {
          return ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              try {
                await bloc.signInWithApple();
              } catch (err) {
                // TODO open diallog with error msg
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.apple,
                  color: Colors.white,
                  size: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Sign in with Apple',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        }

        return Container();
      },
    );

    final googleSignInBtn = StreamBuilder<String>(
      stream: bloc.authState,
      builder: (
        BuildContext context,
        AsyncSnapshot<String> snapshot,
      ) {
        if (!snapshot.hasData || snapshot.hasError) {
          return ElevatedButton(
            onPressed: bloc.googleSignIn,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: AssetImage("assets/google_logo.png"), height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        }

        return Container();
      },
    );

    final facebookSignInBtn = StreamBuilder<String>(
        stream: bloc.authState,
        builder: (
          BuildContext context,
          AsyncSnapshot<String> snapshot,
        ) {
          if (!snapshot.hasData || snapshot.hasError) {
            return ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF4267b2)),
              ),
              onPressed: bloc.facebookSignIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/facebook_logo.png"),
                      height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      'Sign in with Facebook',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Container();
        });

    final brandIcon = Container(
      height: 115.0,
      width: 115.0,
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
    );

    final emailField = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 40.0, right: 40.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: this.foregroundColor,
              width: 0.5,
              style: BorderStyle.solid),
        ),
      ),
      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 00.0),
            child: Icon(
              Icons.alternate_email,
              color: this.foregroundColor,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: TextField(
              key: Key('emailField'),
              style: TextStyle(color: Colors.white),
              controller: bloc.emailFieldController,
              textAlign: TextAlign.start,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: this.foregroundColor),
              ),
            ),
          ),
        ],
      ),
    );

    final pwdField = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        top: 10.0,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: this.foregroundColor,
              width: 0.5,
              style: BorderStyle.solid),
        ),
      ),
      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 00.0),
            child: Icon(
              Icons.lock_open,
              color: this.foregroundColor,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: TextField(
              key: Key('pwdField'),
              style: TextStyle(color: Colors.white),
              obscureText: true,
              textAlign: TextAlign.start,
              controller: bloc.pwdFieldController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: this.foregroundColor),
              ),
            ),
          ),
        ],
      ),
    );

    final failedLoginMsg = StreamBuilder<String>(
      stream: bloc.authState,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError && snapshot.error != 'logout') {
          return Container(
            margin: EdgeInsets.only(top: 2.0, bottom: 3.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          );
        }

        return Container(
          height: 22.0,
        );
      },
    );

    final appleSignErrorMsg = Container(
      child: StreamBuilder(
        stream: bloc.user,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError &&
              snapshot.error.toString().startsWith('Apple Sign In Error: ')) {
            return Text(
              "${snapshot.error}",
              style: TextStyle(color: Colors.red),
            );
          }

          return Container();
        },
      ),
    );

    final signUpBtn = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don\'t have an account yet? '),
        CupertinoButton(
          color: this.foregroundColor,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          onPressed: () {
            Navigator.of(context).pushNamed('/register');
          },
          child: Text(
            'Sign up',
            style: TextStyle(color: const Color(0xFFFE9015)),
          ),
        ),
      ],
    );

    final privacyBtn = CupertinoButton(
      child: Text(
        'Terms & Privacy Policy',
        style: TextStyle(
          color: _linkColor,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () => Navigator.of(context).pushNamed('/disclaimer'),
    );

    final opSignInButton = StreamBuilder<String>(
        stream: bloc.authState,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return Container();
          }

          return ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(OtpSignInScreen.routeName),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.mobileAlt,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Sign in with SMS OTP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        });

    return Scaffold(
      // backgroundColor: Theme.of(context).accentColor,
      body: SingleChildScrollView(
        child: ScreenBg(
          child: SafeArea(
            child: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 16.0,
                  ),
                  brandIcon,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 0),
                    child: Text(
                      "uWin",
                      style: TextStyle(
                          color: this.foregroundColor, fontSize: 24.0),
                    ),
                  ),
                  failedLoginMsg,
                  emailField,
                  pwdField,
                  forgotPwdBtn,
                  loginBtn,
                  SizedBox(height: 8.0),
                  signUpBtn,
                  SizedBox(height: 8.0),
                  Divider(),
                  SizedBox(height: 20.0),
                  Text(
                    'OR CONNECT WITH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  if (Provider.of<AppleSignInAvailable>(context).isAvailable)
                    Column(children: <Widget>[
                      appleSignErrorMsg,
                      appleSignInBtn,
                    ]),
                  GmsAvailable(child: googleSignInBtn),
                  facebookSignInBtn,
                  opSignInButton,
                  SizedBox(height: 8.0),
                  privacyBtn,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
