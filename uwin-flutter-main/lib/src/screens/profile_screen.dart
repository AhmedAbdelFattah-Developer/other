import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uwin_flutter/src/App.dart';
import 'package:uwin_flutter/src/screens/delete_account_screen.dart';
import 'package:uwin_flutter/src/screens/invite_friends_screen.dart';

import '../blocs/providers/auth_block_provider.dart';
import '../models/profile.dart';
import 'edit_profile_screen.dart';
import '../widgets/app_tab_bar.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBlocProvider.of(context);

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('My Profile'),
      ),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: StreamBuilder(
              stream: authBloc.profile,
              builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: CupertinoActivityIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                return _ProfileContent(snapshot.data);
              },
            ),
          ),
          const AppTabBar(currentIndex: 3),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Profile profile;

  _ProfileContent(this.profile);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.35,
                margin: EdgeInsets.only(
                  top: screenWidth * 0.2,
                ),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40.0),
                    Text(
                      '${profile.fName} ${profile.lName}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${profile.email}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      width: screenHeight * 0.35 - 120,
                      height: screenHeight * 0.35 - 120,
                      child: _generateQrImage(profile),
                      padding: EdgeInsets.all(20.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return EditProfileScreen();
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.pencil,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Edit my profile',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(DeleteAccountScreen.routeName);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.no_accounts,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Delete my account',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              if (AppEnvironment().isStage)
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(InviteFriendsScreen.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.forward,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Invite Friends',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/disclaimer');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Disclaimer',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              CupertinoButton(
                onPressed: AuthBlocProvider.of(context).logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.clear_circled_solid,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 60.0),
            ],
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Container(
              width: 80.0,
              height: 80.0,
              margin: EdgeInsets.only(top: screenWidth * 0.2 - 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoTheme.of(context).primaryColor,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _generateQrImage(Profile profile) {
    return QrImageView(
      data: profile.toVCardData(),
      version: QrVersions.auto,
      padding: EdgeInsets.zero,
      size: 400.0,
    );
  }
}
