import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/blocs/providers/flashsells_bloc_provider.dart';
import 'package:uwin_flutter/src/models/flashsale.dart';
import 'package:uwin_flutter/src/widgets/flashsale_tile.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';

class MyWinsFlashSalesScreen extends StatelessWidget {
  final Widget activityIndicator = const SliverFillRemaining(
    child: Center(
      child: CupertinoActivityIndicator(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Flash Sales'),
            trailing: ScanPartnerQrButton(),
          ),
          _buildFlashsales(context)
        ],
      ),
    );
  }

  Widget _buildFlashsales(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final col = ((size.width - 40) / 200).ceil();
    final tileWidth = (size.width - (20 * 2 + (col - 1) * 10)) / col;
    final tileHeight = 261;
    final tileAspectRatio = tileWidth / tileHeight;
    final bloc = FlashsellsProvider.of(context);

    return StreamBuilder(
      stream: bloc.flashsells,
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<Flashsale>>> snapshot) {
        if (snapshot.hasError) {
          return _buildStreamError(snapshot.error);
        }

        if (!snapshot.hasData) {
          return activityIndicator;
        }

        if (snapshot.data['loc'].length == 0) {
          return _buildStreamError('No flashsales available');
        }

        final flashsaleGroup = snapshot.data;

        return SliverPadding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            bottom: 70.0,
            right: 20.0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: tileAspectRatio,
            ),
            delegate: SliverChildListDelegate(
              flashsaleGroup['loc'].map((Flashsale fs) {
                return FlashsaleTile(
                  flashsale: fs,
                  colWidth: null,
                  rowHeight: 150,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreamError(err) {
    return SliverFillRemaining(
      child: Center(
        child: Text('$err'),
      ),
    );
  }
}
