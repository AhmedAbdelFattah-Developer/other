import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/add_other_card_bloc.dart';

class AddOtherCardScreen extends StatefulWidget {
  static const routeName = '/other-cards/new';

  @override
  State<AddOtherCardScreen> createState() => _AddOtherCardScreenState();
}

class _AddOtherCardScreenState extends State<AddOtherCardScreen> {
  String label = '';
  String code = '';

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Add Card')),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => AddOtherCardLabelDialog(
                          label: 'Card Name',
                          text: label,
                          onSave: (value) {
                            setState(() {
                              label = value;
                            });
                          },
                        ),
                      );
                    },
                    title: Text(
                      'CARD',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(label.isEmpty ? 'Enter Card Name' : label),
                    trailing: Icon(CupertinoIcons.chevron_right),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => AddOtherCardLabelDialog(
                          label: 'Card Number',
                          text: code,
                          onSave: (value) {
                            setState(() {
                              code = value;
                            });
                          },
                        ),
                      );
                    },
                    title: Text(
                      'CARD NUMBER',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(code.isEmpty ? 'Enter Card number' : code),
                    trailing: Icon(CupertinoIcons.chevron_right),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Or scan barcode',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navTitleTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            final c = await Provider.of<AddOtherCardBloc>(
                              context,
                              listen: false,
                            ).scan();
                            if (c == null || c == "-1") {
                              return;
                            }

                            setState(
                              () {
                                code = c;
                              },
                            );
                          } catch (err) {
                            debugPrint('$err');
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: Text('Error'),
                                content: Text('An unexpected error has occur.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('Okay'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: code.isEmpty
                            ? Column(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 128.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            : BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: code,
                                style: const TextStyle(fontSize: 20.0),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: theme.primaryColor,
                      child: const Text('Save'),
                      onPressed: () async {
                        try {
                          await Provider.of<AddOtherCardBloc>(context,
                                  listen: false)
                              .save(label, code);
                          Navigator.of(context).pop();
                        } catch (err) {
                          debugPrint('$err');
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Error'),
                              content: Text('An unexpected error has occur'),
                              actions: [
                                CupertinoDialogAction(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Okay')),
                              ],
                            ),
                          );
                        }
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

class AddOtherCardLabelDialog extends StatefulWidget {
  final void Function(String label) onSave;
  final String text;
  final String label;

  AddOtherCardLabelDialog({
    @required this.onSave,
    @required this.text,
    @required this.label,
    Key key,
  }) : super(key: key);

  @override
  State<AddOtherCardLabelDialog> createState() =>
      _AddOtherCardLabelDialogState();
}

class _AddOtherCardLabelDialogState extends State<AddOtherCardLabelDialog> {
  final controller = TextEditingController();
  String errMsg = '';

  @override
  void initState() {
    controller.text = widget.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.label),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(controller: controller),
          if (errMsg.isNotEmpty)
            Text(
              errMsg,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('Okay'),
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              setState(() {
                errMsg = 'Cannot be blank';
              });
              return;
            }

            errMsg = '';
            widget.onSave(controller.text);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
