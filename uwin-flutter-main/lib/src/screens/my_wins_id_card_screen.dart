import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/other_cards_bloc.dart';
import 'package:uwin_flutter/src/models/other_card.dart';

class MyWinsIDCardScreen extends StatelessWidget {
  static const routeName = '/my-wins/other-cards/id';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('ID Card')),
      child: SafeArea(
        child: StreamBuilder<OtherCard>(
          stream: Provider.of<OtherCardsBloc>(context, listen: false).nid,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.data.number == null) {
              return ScanRequestMyWinsIDCard();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IDCard(snapshot.data.number),
                SizedBox(height: 8.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: _ScanButton(title: Text('Rescan')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IDCard extends StatelessWidget {
  final String number;

  _IDCard(this.number);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: number,
                  style: const TextStyle(fontSize: 20.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
@visibleForTesting
class ScanRequestMyWinsIDCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: ListTile(
              title: Text('ID Card'),
              subtitle: Text('Scan the bar code at the back of your ID Card'),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            child: _ScanButton(),
          )
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final Widget title;

  const _ScanButton({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoTheme.of(context).primaryColor,
      child: title ?? Text('Scan'),
      onPressed: () async {
        try {
          await Provider.of<OtherCardsBloc>(
            context,
            listen: false,
          ).scanAndSave();
        } catch (err) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Error'),
              content: Column(
                children: [
                  Text(
                    'Could not scan or save your ID Card Number',
                  ),
                  Text(err.toString()),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Okay'),
                  onPressed: () {
                    final nav = Navigator.of(context);
                    if (nav.canPop()) {
                      nav.pop();
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
