import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uwin_flutter/src/blocs/win_credits_bloc.dart';
import 'package:uwin_flutter/src/models/win_credits_content.dart';

import '../widgets/app_tab_bar.dart';

const _primaryColor = Color(0xFFF1582D);
const _primaryColorContrast = Colors.white;

class WinCreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _NavBar(),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            StreamBuilder<WinCreditsContent>(
                stream: Provider.of<WinCreditsBloc>(context).winCredits,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('[win_credit_screen] ${snapshot.error}');

                    return Center(
                      child: Text(
                        'Could not get win credit information from server',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  }

                  return _WinCreditScreenBody(snapshot.data);
                }),
            const AppTabBar(
              currentIndex: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _WinCreditScreenBody extends StatelessWidget {
  const _WinCreditScreenBody(
    this.winCredits, {
    Key key,
  }) : super(key: key);

  final WinCreditsContent winCredits;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(winCredits.imageUrl),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        color: Colors.black.withAlpha(125),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              winCredits.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _primaryColorContrast,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              winCredits.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _primaryColorContrast,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48.0),
            Text(
              winCredits.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _primaryColorContrast,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32.0),
            CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              child: Text(winCredits.registerButtonLabel),
              onPressed: () => _launchURL(
                context,
                'https://research.kantartns.io/community/myVoice/myvoice/Account/SignUp',
              ),
            ),
            SizedBox(height: 16.0),
            CupertinoButton(
              color: Colors.white,
              child: Text(
                'Show current vouchers',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/my-wins/vouchers'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final height = 80.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Container(
        height: height,
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/myvoice_logo.png'),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              child: Text(
                'Go to website',
                style: TextStyle(color: _primaryColorContrast),
              ),
              onPressed: () =>
                  _launchURL(context, 'https://myvoice.kantartns.io/'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}

_launchURL(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('[win_credits_screen] Could not launch $url');
    _showDialog(context, url);
  }
}

void _showDialog(BuildContext context, String url) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text("Error"),
        content: new Text("Could not open URL\n\n$url"),
        actions: <Widget>[
          TextButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
