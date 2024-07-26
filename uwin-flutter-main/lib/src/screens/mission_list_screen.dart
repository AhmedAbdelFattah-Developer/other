import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uwin_flutter/src/blocs/mission_list_bloc.dart';
import 'package:uwin_flutter/src/models/mission.dart';
import 'package:uwin_flutter/src/screens/edit_profile_screen.dart';
import 'package:uwin_flutter/src/screens/mission_success_screen.dart';
import 'package:uwin_flutter/src/widgets/currency_number_format.dart';

class MissionListScreen extends StatelessWidget {
  static const bannerUrl =
      'https://firebasestorage.googleapis.com/v0/b/uwin-201010.appspot.com/o/assets%2Fistockphoto-823928832-612x612.jpeg?alt=media&token=d814e460-041a-40ab-8b52-492f68006e9d';
  static const routeName = '/my-wins/missions';

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MissionListBloc>(context, listen: false);
    return Material(
      child: CupertinoPageScaffold(
        // navigationBar: CupertinoNavigationBar(middle: Text('Missions')),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: CupertinoTheme.of(context).primaryColor,
                  child: Icon(CupertinoIcons.chevron_back),
                  maxRadius: 20,
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              expandedHeight: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: CupertinoTheme.of(context).primaryColor,

              // title: Text('Mission'),
              flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(bannerUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
            ),
            SliverToBoxAdapter(child: _TitleBar()),
            StreamBuilder<List<Mission>>(
              stream: bloc.list,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('${snapshot.error}')),
                  );
                }

                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }

                if (snapshot.data.isEmpty) {
                  return SliverToBoxAdapter(
                      child: Center(child: Text('No mission available')));
                }

                return SliverList(
                  delegate: SliverChildListDelegate(
                    snapshot.data.map((mission) {
                      return GestureDetector(
                        onTap: () async {
                          if (mission.isCompleted) {
                            Navigator.of(context).pushNamed(
                              '/${MissionSuccessScreen.routeFirstNode}/${mission.id}',
                            );

                            return;
                          }

                          switch (mission.task) {
                            case 'completeProfile':
                              Navigator.of(context)
                                  .pushNamed(EditProfileScreen.routeName);
                              break;
                            case 'questionnaire':
                              try {
                                final url = await bloc.getUrl(mission);
                                _launchURL(url);
                              } catch (e) {
                                debugPrint("error: generate mission url, $e");
                              }

                              break;
                          }
                        },
                        child: _ListTile(mission: mission),
                      );
                    }).toList(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _RewardLabel extends StatelessWidget {
  final Mission mission;
  final style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
  );

  _RewardLabel({Key key, this.mission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mission.rewardType) {
      case 'voucherGroup':
        return CurrencyNumberFormat(
          number: mission.voucherAmount * 100,
          style: style,
        );

      case 'points':
      case 'myVoicePoint':
        return CurrencyNumberFormat(
          number: mission.points * 100,
          symbol: 'Points ',
          decimalDigits: 0,
          style: style,
        );

      default:
        return Center(
          child: Text(
            'N/A',
            style: style,
          ),
        );
    }
  }
}

class _ListTile extends StatelessWidget {
  final Mission mission;

  const _ListTile({Key key, @required this.mission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: mission.isCompleted
                  ? Colors.green.shade900
                  : CupertinoTheme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          child: Icon(
                            mission.task == 'completeProfile'
                                ? Icons.person
                                : Icons.checklist,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${mission.isCompleted ? '✓ ' : ''}${mission.title}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.0),
                              _VoucherGroupReward(mission: mission)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.0),
                  SizedBox(
                    width: 100.0,
                    child: Center(
                      child: _RewardLabel(
                        mission: mission,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
              top: -5,
              right: 137.5,
              child: _DashedLine(
                color: Colors.white,
                heightContainer: 100,
              )),
          Positioned(
              top: -5,
              right: 130,
              child: Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              )),
          Positioned(
            bottom: -5,
            right: 130,
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherGroupReward extends StatelessWidget {
  final Mission mission;
  static const textStyle = TextStyle(color: Colors.white);

  _VoucherGroupReward({Key key, @required this.mission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mission.isCompleted) {
      return const Text('Completed', style: textStyle);
    }

    if (mission.rewardType != 'voucherGroup') {
      return const Text('Get more points', style: textStyle);
    }

    return FutureBuilder<List<String>>(
      future: Provider.of<MissionListBloc>(context)
          .fetchMissionVouchers(mission.id),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error;
          if (err is Error) {
            debugPrint('${err.stackTrace}');
          }
          debugPrint('error: ${snapshot.error}');
          return Text('${snapshot.error}', style: textStyle);
        }

        if (!snapshot.hasData) {
          return const Text('Loading...', style: textStyle);
        }

        if (snapshot.data.isEmpty) {
          return const Text('No voucher available', style: textStyle);
        }

        return Text(
          snapshot.data.join('\n'),
          style: textStyle,
        );
      }),
    );
  }
}

class _TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Missions',
              style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final double height;
  final double heightContainer;
  final Color color;
  final double dashWidth;

  const _DashedLine({
    this.color = Colors.black,
    this.height = 3.0,
    this.heightContainer = 70,
    this.dashWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightContainer,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxHeight = constraints.constrainHeight();
          final dashHeight = height;
          final dashCount = (boxHeight / (2 * dashHeight)).floor();
          return Flex(
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.vertical,
          );
        },
      ),
    );
  }
}
