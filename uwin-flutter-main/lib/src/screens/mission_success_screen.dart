import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/mission_success_bloc.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/screens/mission_list_screen.dart';
import 'package:uwin_flutter/src/widgets/voucher_grid_item.dart';

class MissionSuccessScreen extends StatelessWidget {
  static const routeFirstNode = 'mission-completed';
  final String mid;

  MissionSuccessScreen({this.mid});

  @override
  Widget build(BuildContext context) {
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
                    image:
                        CachedNetworkImageProvider(MissionListScreen.bannerUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
            ),
            SliverToBoxAdapter(child: _TitleBar()),
            _VoucherList(mid: mid),
          ],
        ),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Missions Completed',
              style: TextStyle(
                fontSize: 18.0,
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'You have successfully completed the mission.\nPlease find below your vouchers. They will also be available in myWin Section',
              textAlign: TextAlign.center,
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

class _VoucherList extends StatelessWidget {
  final String mid;

  _VoucherList({this.mid});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MissionSuccessBloc>(context, listen: false);
    return FutureBuilder<List<Voucher>>(
      future: bloc.getVouchers(mid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return SliverToBoxAdapter(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildListDelegate(
            snapshot.data
                .map((v) => Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        bottom: 16.0,
                      ),
                      child: VoucherGridItem(v),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
