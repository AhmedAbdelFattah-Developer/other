import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/dialogs/show_gift_voucher_dialog.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';
import 'package:uwin_flutter/src/widgets/ticket_card.dart';

import '../blocs/providers/my_wins_bloc_provider.dart';

class MyWinsGiftVouchersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Gift Vouchers'),
            trailing: ScanPartnerQrButton(),
          ),
          _buildGiftVoucher(context),
        ],
      ),
    );
  }

  Widget _buildStreamError(err) {
    return SliverFillRemaining(
      child: Center(
        child: Text('$err'),
      ),
    );
  }

  final Widget activityIndicator = const SliverFillRemaining(
    child: Center(
      child: CupertinoActivityIndicator(),
    ),
  );

  Widget _buildGiftVoucher(BuildContext context) {
    final tileAspectRatio = 1.4;
    final bloc = MyWinsBlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.giftVoucher,
      builder:
          (BuildContext context, AsyncSnapshot<List<GiftVoucher>> snapshot) {
        if (snapshot.hasError) {
          assert(() {
            final Error err = snapshot.error;
            print(err.stackTrace);
            return true;
          }());

          return _buildStreamError(snapshot.error);
        }

        if (!snapshot.hasData) {
          return activityIndicator;
        }

        if (snapshot.data.length == 0) {
          return _buildStreamError('No voucher available');
        }

        return SliverPadding(
          padding: EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            bottom: 70.0,
            right: 20.0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              snapshot.data
                  .asMap()
                  .entries
                  .map(
                    (entry) => TicketCard(
                      stripped: entry.key % 2 == 0,
                      onPress: () => showGiftVoucherDialog(
                        context,
                        entry.value,
                      ),
                      imageUrl:
                          'https://u-win.shop/files/shops/${entry.value.shopId}/${entry.value.photoPath}',
                      title: entry.value.shopName,
                      amount: '${(entry.value.amount / 100).round()}',
                      colors: entry.key % 2 == 0
                          ? [
                              Color(0xFFE27F34),
                              Color(0xFFF59547),
                            ]
                          : [
                              Color(0xFF4092CA),
                              Color(0xFF50A7DF),
                            ],
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
