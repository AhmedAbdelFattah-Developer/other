import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/other_cards_bloc.dart';
import 'package:uwin_flutter/src/models/other_card.dart';
import 'package:uwin_flutter/src/screens/add_other_card_screen.dart';
import 'package:uwin_flutter/src/screens/my_win_other_card_details_screen.dart';

class MyWinsOtherCardsScreen extends StatelessWidget {
  static const routeName = '/my-wins/other-cards';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Other Cards'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Add card'),
          onPressed: () {
            Navigator.of(context).pushNamed(AddOtherCardScreen.routeName);
          },
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<List<OtherCard>>(
          stream: Provider.of<OtherCardsBloc>(
            context,
            listen: false,
          ).list,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            final list = snapshot.data;

            if (list.isEmpty) {
              return Center(child: Text('No card found.'));
            }

            final colors = [
              Colors.purple,
              Colors.teal,
              Colors.yellow,
              Colors.red,
              Colors.blue,
              Colors.orange,
              Colors.green,
            ];

            return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                children: snapshot.data.asMap().entries.map((e) {
                  final path = e.value.getPath(CardSides.front);
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                      MyWinOtherCardDetailsScreen.routeName,
                      arguments: <String, dynamic>{'id': e.value.id},
                    ),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: colors[e.key % colors.length].withOpacity(0.3),
                          child: Center(
                            child: Text(
                              e.value.label,
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .navTitleTextStyle
                                  .copyWith(color: Colors.white, shadows: [
                                Shadow(
                                  offset: Offset(3.0, 3.0),
                                  blurRadius: 8.0,
                                  color: Colors.black,
                                ),
                              ]),
                            ),
                          ),
                        ),
                        decoration: path.isEmpty
                            ? null
                            : BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                    'https://us-central1-uwin-201010.cloudfunctions.net/userApi/v1/users/:uid/download?path=$path',
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // child: Card(
                    //   color: colors[e.key % colors.length],
                    //   child: Center(
                    //     child: Text(
                    //       e.value.label,
                    //       style: CupertinoTheme.of(context)
                    //           .textTheme
                    //           .navTitleTextStyle,
                    //     ),
                    //   ),
                    // ),
                  );
                }).toList());
          },
        ),
      ),
    );
  }
}
