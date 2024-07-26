import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uwin_flutter/src/blocs/invite_friends_bloc.dart';

void _inviteFriendsHandler(BuildContext context, String code) {
  Share.share(
    'Join uWin, you will receive voucher & more https://uwin.mu/portal/register?userType=$code',
  );
}

const _accentColor = Color(0xFFEB4432);
const _bgColor = Color(0xFF1CB099);
const _logoSrc = 'assets/uwin-logo-v3.png';
const _logoHalfSrc = 'assets/uwin-logo-v3-half.png';

class InviteFriendsScreen extends StatelessWidget {
  static const routeName = '/invite-friends';

  final void Function(BuildContext context, String code) inviteFriendsHandler;

  const InviteFriendsScreen(
      {Key key, this.inviteFriendsHandler = _inviteFriendsHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFC4EAE4),
        trailing: SizedBox(width: 24.0),
        middle: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_logoHalfSrc),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  maxRadius: 75.0,
                  backgroundColor: CupertinoColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.asset(_logoSrc),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Referral',
                style: TextStyle(
                  fontSize: 40,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'How it work',
                style: TextStyle(
                  fontSize: 28,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Text(
                  'Invite your friends to join uWin\nand earn vouchers when friends joins',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 80.0,
                margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                    )
                  ],
                ),
                child: StreamBuilder<String>(
                    stream:
                        Provider.of<InviteFriendsBloc>(context, listen: false)
                            .referalCode,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return Center(child: CupertinoActivityIndicator());
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.data,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                              fontSize: 28.0,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Your referral code',
                            style: TextStyle(
                              color: _bgColor,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      );
                    }),
              ),
              StreamBuilder<Object>(
                  stream: Provider.of<InviteFriendsBloc>(context, listen: false)
                      .referalCode,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(24.0),
                        key: Key('invite-friends-button'),
                        child: Text(
                          'INVITE FRIENDS',
                          style: TextStyle(
                              fontSize: 28,
                              color: _bgColor,
                              fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => inviteFriendsHandler(
                          context,
                          snapshot.data,
                        ),
                      ),
                    );
                  }),
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: EdgeInsets.all(32.0),
                  padding: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'Invited',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                    trailing: InvitedCounter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvitedCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream:
            Provider.of<InviteFriendsBloc>(context, listen: false).invitedCount,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return CupertinoActivityIndicator();
          }

          return Text(
            snapshot.data.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
              fontSize: 18.0,
            ),
          );
        });
  }
}
