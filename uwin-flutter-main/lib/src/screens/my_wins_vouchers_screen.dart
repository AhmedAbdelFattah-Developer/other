import 'package:flutter/cupertino.dart';
import 'package:uwin_flutter/src/dialogs/show_voucher_dialog.dart';
import 'package:uwin_flutter/src/widgets/scan_partner_qr_partner.dart';
import 'package:uwin_flutter/src/widgets/ticket_card.dart';
import '../blocs/providers/my_wins_bloc_provider.dart';
import '../models/voucher.dart';

class MyWinsVouchersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Vouchers'),
            trailing: ScanPartnerQrButton(),
          ),
          _buildVoucher(context),
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

  Widget _buildVoucher(BuildContext context) {
    final bloc = MyWinsBlocProvider.of(context);

    return StreamBuilder(
      stream: bloc.vouchers,
      builder: (BuildContext context, AsyncSnapshot<List<Voucher>> snapshot) {
        if (snapshot.hasError) {
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
              snapshot.data.asMap().entries.map((entry) {
                final index = entry.key;
                final voucher = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TicketCard(
                    stripped: index % 2 == 0,
                    imageUrl:
                        'https://u-win.shop/files/shops/${voucher.shopId}/${voucher.photoPath}',
                    title: voucher.shopName,
                    onPress: () => showVoucherDialog(context, voucher),
                    amount: '${voucher.amount}',
                    colors: index % 2 == 0
                        ? [
                            Color(0xFFE27F34),
                            Color(0xFFF59547),
                          ]
                        : [
                            Color(0xFF4092CA),
                            Color(0xFF50A7DF),
                          ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
