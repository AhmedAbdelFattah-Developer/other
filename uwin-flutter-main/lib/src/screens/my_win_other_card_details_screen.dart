import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/add_other_card_bloc.dart';
import 'package:uwin_flutter/src/blocs/my_win_other_card_details_bloc.dart';
import 'package:uwin_flutter/src/models/other_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uwin_flutter/src/screens/add_other_card_screen.dart';

class MyWinOtherCardDetailsScreen extends StatelessWidget {
  static const routeName = '/other-cards/details';
  final String id;

  const MyWinOtherCardDetailsScreen({
    Key key,
    @required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OtherCard>(
        stream: Provider.of<MyWinOtherCardDetailsBloc>(context, listen: false)
            .find(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CupertinoPageScaffold(
              child: Center(child: Text('${snapshot.error}')),
            );
          }

          if (!snapshot.hasData) {
            return const CupertinoPageScaffold(
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          return Material(
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: CupertinoTheme.of(context).primaryColor,
                  actions: [
                    PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: 1,
                          ),
                        ];
                      },
                      onSelected: (_) {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Are you sure?'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('Yes'),
                                onPressed: _onDelete(context, id),
                              ),
                              CupertinoDialogAction(
                                child: Text('No'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Details'),
                      Tab(text: 'Front'),
                      Tab(text: 'Back'),
                      Tab(text: 'Receipt'),
                    ],
                  ),
                  title: const Text('Card Details'),
                ),
                body: TabBarView(
                  children: [
                    _DetailsTab(card: snapshot.data),
                    _CardImageTab(card: snapshot.data, side: CardSides.front),
                    _CardImageTab(card: snapshot.data, side: CardSides.back),
                    Center(
                      child: Text(
                        'Comming soon',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _DetailsTab extends StatelessWidget {
  final OtherCard card;

  const _DetailsTab({Key key, @required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              card.label,
              style: theme.textTheme.navLargeTitleTextStyle,
            ),
            trailing: Icon(CupertinoIcons.pencil),
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => AddOtherCardLabelDialog(
                  label: 'label',
                  text: card.label,
                  onSave: (value) async {
                    await Provider.of<MyWinOtherCardDetailsBloc>(
                      context,
                      listen: false,
                    ).saveLabel(card.id, value);
                  },
                ),
              );
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RotateScreenDialog(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: card.number,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: card.number,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: theme.primaryColor,
              onPressed: () async {
                final c = await Provider.of<AddOtherCardBloc>(
                  context,
                  listen: false,
                ).scan();
                if (c == null || c == "-1") {
                  return;
                }
                await Provider.of<MyWinOtherCardDetailsBloc>(
                  context,
                  listen: false,
                ).saveCode(card.id, c);
              },
              child: Text('Scan Again'),
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: theme.primaryColor,
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => AddOtherCardLabelDialog(
                    label: 'Card number',
                    text: card.number,
                    onSave: (value) async {
                      await Provider.of<MyWinOtherCardDetailsBloc>(
                        context,
                        listen: false,
                      ).saveCode(card.id, value);
                    },
                  ),
                );
              },
              child: Text('Edit Card Number'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardImageTab extends StatelessWidget {
  final OtherCard card;
  final CardSide side;

  const _CardImageTab({
    Key key,
    @required this.card,
    @required this.side,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final path = card.getPath(side);
    final imgSrc = path.isEmpty
        ? ''
        : 'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/:uid/download?path=$path';
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _showImageDialog(context, imgSrc),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: path.isEmpty
                      ? Icon(CupertinoIcons.camera_fill, size: 192)
                      : Container(
                          height: 192,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: CachedNetworkImageProvider(imgSrc),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              child: Text('Take Picture'),
              onPressed: _onTakePicture(
                context,
                ImageSource.camera,
                side,
                card.id,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoTheme.of(context).primaryColor,
              child: Text('From Gallery'),
              onPressed: _onTakePicture(
                context,
                ImageSource.gallery,
                side,
                card.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> Function() _onTakePicture(
  BuildContext context,
  ImageSource imageSource,
  CardSide side,
  String id,
) {
  return () async {
    try {
      final bloc = Provider.of<MyWinOtherCardDetailsBloc>(
        context,
        listen: false,
      );
      final ImagePicker _picker = ImagePicker();
      final XFile photo = await _picker.pickImage(
        source: imageSource,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 768,
      );
      if (photo == null) {
        return;
      }
      final path = await bloc.uploadImage(
        id,
        side.filename,
        await photo.readAsBytes(),
      );
      await bloc.saveImage(side, id, path);
    } catch (err) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error has occurred.\n\n$err'),
          actions: [
            CupertinoDialogAction(
              child: Text('Okay'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  };
}

Future<void> Function() _onDelete(BuildContext context, String id) {
  return () async {
    final nav = Navigator.of(context);
    nav.pop();
    if (nav.canPop()) {
      nav.pop();
    }

    final bloc = Provider.of<MyWinOtherCardDetailsBloc>(
      context,
      listen: false,
    );
    await bloc.delete(id);
  };
}

void Function() _showImageDialog(BuildContext context, String imgSrc) {
  return () {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RotateScreenDialog(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: CachedNetworkImageProvider(imgSrc),
              ),
            ),
          ),
        ),
      ),
    );
  };
}

class RotateScreenDialog extends StatefulWidget {
  final Widget child;

  const RotateScreenDialog({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  State<RotateScreenDialog> createState() => _RotateScreenDialogState();
}

class _RotateScreenDialogState extends State<RotateScreenDialog> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void deactivate() {
    super.deactivate();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: GestureDetector(
          onTap: () async {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.of(context).pop();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
