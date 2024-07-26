import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../blocs/providers/forget_password_bloc_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const AssetImage logo = AssetImage('assets/images/uwin_logo.png');
  static const Color backgroundColor1 = Colors.black54;
  static const Color backgroundColor2 = Colors.black38;
  static const Color highlightColor = Colors.white30;
  static const Color foregroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final bloc = ForgetPasswordBlocProvider.of(context);

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

    final emailField = Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 40.0, right: 40.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: foregroundColor, width: 0.5, style: BorderStyle.solid),
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
              color: foregroundColor,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: bloc.emailCtrl,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: foregroundColor),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFE9015),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: StreamBuilder<ForgetPasswordState>(
              stream: bloc.state,
              builder: (BuildContext context,
                  AsyncSnapshot<ForgetPasswordState> snapshot) {
                if (snapshot.data == ForgetPasswordStates.completed) {
                  return Column(children: <Widget>[
                    SizedBox(
                      height: 75.0,
                    ),
                    brandIcon,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 40),
                      child: Text(
                        "uwin",
                        style:
                            TextStyle(color: foregroundColor, fontSize: 32.0),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                        'Instruction has been sent to:\n ${bloc.emailCtrl.text}'),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: CupertinoButton(
                        color: Colors.white.withAlpha(200),
                        child: Text('Back to login',
                            style: TextStyle(
                              color: Colors.black87,
                            )),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ]);
                }
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 75.0,
                    ),
                    brandIcon,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0, 40),
                      child: Text(
                        "uwin",
                        style:
                            TextStyle(color: foregroundColor, fontSize: 32.0),
                      ),
                    ),
                    Container(
                      height:
                          snapshot.data == ForgetPasswordStates.failed ? 25 : 0,
                      child: snapshot.data == ForgetPasswordStates.failed
                          ? Text(
                              'The supplied email is invalid',
                              style: TextStyle(
                                color: Colors.red[900],
                              ),
                            )
                          : null,
                    ),
                    emailField,
                    SizedBox(height: 30.0),
                    snapshot.data == ForgetPasswordStates.pending
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 12.0,
                            ),
                            child: CupertinoActivityIndicator(),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 40.0),
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              color: Colors.white,
                              child: Text(
                                'Request Password',
                                style: TextStyle(
                                  color: const Color(0xFFFE9015),
                                ),
                              ),
                              onPressed: bloc.requestPassword,
                            ),
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
                );
              }),
        ),
      ),
    );
  }
}
