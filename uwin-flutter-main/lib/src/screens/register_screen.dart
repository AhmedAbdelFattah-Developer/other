import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/widgets/screen_bg.dart';

import '../blocs/providers/register_bloc_provider.dart';

class RegisterScreen extends StatelessWidget {
  final Color backgroundColor1 = Colors.black54;
  final Color backgroundColor2 = Colors.black38;
  final Color highlightColor = Colors.white30;
  final Color foregroundColor = Colors.white;
  final AssetImage logo = AssetImage('assets/images/uwin_logo.png');

  @override
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
            image: logo,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );

    return Scaffold(
      body: ScreenBg(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 75.0,
                ),
                brandIcon,
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 40),
                  child: Text(
                    "uWin",
                    style:
                        TextStyle(color: this.foregroundColor, fontSize: 32.0),
                  ),
                ),
                _RegisterForm(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(
                    left: 40.0,
                    right: 40.0,
                    top: 10.0,
                    bottom: 20.0,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20.0),
                            color: Colors.transparent,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('< Return to login page')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  __RegisterFormState createState() => __RegisterFormState();
}

class __RegisterFormState extends State<_RegisterForm> {
  final Color backgroundColor1 = Colors.black54;

  final Color backgroundColor2 = Colors.black38;

  final Color highlightColor = Colors.white30;

  final Color foregroundColor = Colors.white;

  final emailFieldController = TextEditingController();

  final confirmEmailFieldController = TextEditingController();

  final pwdFieldController = TextEditingController();

  final referralCodeFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = Provider.of<RegisterBloc>(context, listen: false);

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
            child: StreamBuilder<String>(
                stream: bloc.email,
                builder: (context, snapshot) {
                  return TextField(
                    key: Key('registerForm.email'),
                    style: TextStyle(color: Colors.white),
                    controller: emailFieldController,
                    onChanged: (String val) {
                      bloc.changeEmail(val);
                    },
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                      hintStyle: TextStyle(color: this.foregroundColor),
                      errorText: snapshot.hasError
                          ? (snapshot.error as StateError).message
                          : null,
                    ),
                  );
                }),
          ),
        ],
      ),
    );

    final confirmEmailField = Container(
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
            child: StreamBuilder<String>(
                stream: bloc.confirmEmail,
                builder: (context, snapshot) {
                  return TextField(
                    key: Key('registerForm.confirmEmail'),
                    style: TextStyle(color: Colors.white),
                    controller: confirmEmailFieldController,
                    textAlign: TextAlign.start,
                    onChanged: (String val) {
                      bloc.changeConfirmEmail(val);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm Email',
                      hintStyle: TextStyle(color: this.foregroundColor),
                      errorText: snapshot.hasError
                          ? (snapshot.error as StateError).message
                          : null,
                    ),
                  );
                }),
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
              key: Key('registerForm.password'),
              style: TextStyle(color: Colors.white),
              obscureText: true,
              textAlign: TextAlign.start,
              controller: pwdFieldController,
              onChanged: (String val) {
                bloc.changePassword(val);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: this.foregroundColor),
                  hintText: 'Password'),
            ),
          ),
        ],
      ),
    );

    final referralCode = Container(
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
              CupertinoIcons.person,
              color: this.foregroundColor,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: StreamBuilder<String>(
                stream: bloc.referralCode,
                builder: (context, snapshot) {
                  return TextField(
                    key: Key('registerForm.referralCode'),
                    style: TextStyle(color: Colors.white),
                    controller: referralCodeFieldController,
                    onChanged: (String val) {
                      bloc.changeReferralCode(val);
                    },
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Referral Code',
                      hintStyle: TextStyle(color: this.foregroundColor),
                      errorText: snapshot.hasError
                          ? (snapshot.error as StateError).message
                          : null,
                    ),
                  );
                }),
          ),
        ],
      ),
    );

    final failedLoginMsg = StreamBuilder<StateError>(
      stream: bloc.formErrors,
      builder: (BuildContext context, AsyncSnapshot<StateError> snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: EdgeInsets.only(bottom: 15.0),
            child: Text(snapshot.data.message,
                style: TextStyle(color: Colors.red.shade900)),
          );
        }

        return Container(
          height: 32.0,
        );
      },
    );

    final acceptDisclaimerField = StreamBuilder<bool>(
      stream: bloc.terms,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(
            left: 40.0,
            right: 40.0,
            top: 10.0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: Checkbox(
                      value: !snapshot.hasError && snapshot.data == true,
                      onChanged: (value) {
                        bloc.setTerms(value);
                      },
                    ),
                  ),
                  Text(
                    'I agree to the ',
                    style: TextStyle(color: Colors.white.withAlpha(200)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/disclaimer');
                    },
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (snapshot.hasError)
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade800,
                  ),
                ),
            ],
          ),
        );
      },
    );

    final registerBtn = Container(
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
            child: StreamBuilder<bool>(
                stream: bloc.showSpinner,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<bool> snapshot,
                ) {
                  if (!snapshot.hasData || snapshot.data == false) {
                    return CupertinoButton(
                      key: Key('registerForm.registerButton'),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      color: theme.hintColor,
                      onPressed: () async {
                        final ok = await bloc.register(
                          emailFieldController.text,
                          pwdFieldController.text,
                          referralCodeFieldController.text,
                        );

                        if (ok) {
                          Navigator.of(context)
                              .pushReplacementNamed('/edit-profile');
                        }
                      },
                      child: Text(
                        "Register",
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

    return Column(
      children: <Widget>[
        failedLoginMsg,
        emailField,
        confirmEmailField,
        pwdField,
        referralCode,
        acceptDisclaimerField,
        registerBtn,
      ],
    );
  }
}
