import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/widgets/GmsAvailable.dart';
import '../screens/shop_screen.dart';
import '../models/pos.dart';
import '../blocs/pos_bloc.dart';

class PosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(),
      child: StreamBuilder(
          stream: Provider.of<PosBloc>(context).pos,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error));
            }

            if (!snapshot.hasData) {
              return Center(child: CupertinoActivityIndicator());
            }

            return _buildBody(context, snapshot.data);
          }),
    );
  }

  Widget _buildBody(BuildContext context, Pos pos) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeadImage(context, pos),
            _buildHeading(context, pos),
            _buildTitle(pos.name),
            _buildDescription(context, pos),
            GmsAvailable(child: _buildTitle('Location')),
            GmsAvailable(child: SizedBox(height: 20.0)),
            GmsAvailable(child: _buildMap(context, pos)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Pos pos) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(20.0),
      child: Text(
        pos.description,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF9F9F9F),
        ),
      ),
    );
  }

  Widget _buildTitle(text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeadImage(BuildContext context, Pos pos) {
    return Container(
      height: 250.0,
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        image: new DecorationImage(
          image: NetworkImage(
            'https://u-win.shop/files/shops/${pos.shop.id}/${pos.photoPath.first}',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context, Pos pos) {
    final image =
        pos.photoPath.length > 2 ? pos.photoPath[1] : pos.photoPath.first;

    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              image: new DecorationImage(
                image: NetworkImage(
                  'https://u-win.shop/files/shops/${pos.shop.id}/$image',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, Pos pos) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      child: MarkerIconsBody(<Pos>[pos]),
    );
  }
}
