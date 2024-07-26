import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/send_gift_voucher_bloc.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/user.dart';
import 'package:uwin_flutter/src/widgets/gift_voucher_grid_item.dart';

class SendGiftVoucherScreen extends StatelessWidget {
  final GiftVoucher giftVoucher;

  SendGiftVoucherScreen(this.giftVoucher);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SendGiftVoucherBloc>(context);
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Send Gift Voucher'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GiftVoucherGridItem(
                  giftVoucher,
                  showQrCode: false,
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Send voucher to:'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      StreamBuilder<String>(
                          stream: bloc.email,
                          builder: (context, snapshot) {
                            // TODO remove debug
                            print('Error: ${snapshot.error}');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CupertinoTextField(
                                  placeholder: 'Ex: name@domain.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text('Email: '),
                                  ),
                                  onChanged: bloc.changeEmail,
                                ),
                                if (snapshot.hasError)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      '${snapshot.error}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            );
                          }),
                      SizedBox(height: 16.0),
                      StreamBuilder<User>(
                        stream: bloc.user,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(
                                '[send_gift_voucher_screen] ${snapshot.error}');
                          }

                          if (!snapshot.hasData || snapshot.hasError) {
                            return Container();
                          }

                          return _SendButton(snapshot.data, giftVoucher);
                        },
                      ),
                    ],
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

class _SendButton extends StatefulWidget {
  _SendButton(this.user, this.giftVoucher);

  final User user;
  final GiftVoucher giftVoucher;

  @override
  __SendButtonState createState() => __SendButtonState();
}

class __SendButtonState extends State<_SendButton> {
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SendGiftVoucherBloc>(context);
    return StreamBuilder<bool>(
        stream: bloc.valid,
        builder: (context, snapshot) {
          return Container(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              child: showSpinner
                  ? CupertinoActivityIndicator()
                  : Text(
                      'Send',
                      style: TextStyle(
                        color:
                            snapshot.data == true ? Colors.white : Colors.grey,
                      ),
                    ),
              onPressed: snapshot.data == true && !showSpinner
                  ? () async {
                      try {
                        setState(() {
                          showSpinner = true;
                        });
                        await bloc.submit(
                          widget.user,
                          widget.giftVoucher,
                        );
                        showCupertinoDialog(
                          context: context,
                          builder: (dialogContext) => CupertinoAlertDialog(
                            title: new Text("Voucher sent"),
                            content: new Text(
                              "The voucher has been successfully sent.",
                            ),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: new Text("Close"),
                                onPressed: () => Navigator.of(dialogContext)
                                    .pushNamedAndRemoveUntil('/', (_) => false),
                              ),
                            ],
                          ),
                        );
                      } catch (err) {
                        print('[send_gift_voucher_screen] Error: $err');
                        showCupertinoDialog(
                          context: context,
                          builder: (dialogContext) => CupertinoAlertDialog(
                            title: new Text("Error"),
                            content: new Text("$err"),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: new Text("Close"),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                        );
                      } finally {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  : null,
            ),
          );
        });
  }
}
