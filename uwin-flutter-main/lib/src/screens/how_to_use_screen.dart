import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/how_to_use_bloc.dart';
import 'package:uwin_flutter/src/models/post.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class HowToUseScreen extends StatelessWidget {
  static const routeName = '/how-to-use';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('How To Use?')),
      child: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: Provider.of<HowToUseBloc>(context, listen: false).posts,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.data.isEmpty) {
              return Center(child: Text('No result'));
            }

            return _buildList(context, snapshot.data);
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Post> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _HowToUseVideoItem(
        list[index],
      ),
    );
  }
}

class _HowToUseVideoItem extends StatefulWidget {
  final Post post;
  const _HowToUseVideoItem(
    this.post, {
    Key key,
  }) : super(key: key);

  @override
  __HowToUseVideoItemState createState() => __HowToUseVideoItemState();
}

class __HowToUseVideoItemState extends State<_HowToUseVideoItem> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.post.videoId,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: Colors.black,
              child: YoutubePlayerIFrame(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
            ListTile(title: Text(widget.post.title ?? '')),
          ],
        ),
      ),
    );
  }
}
