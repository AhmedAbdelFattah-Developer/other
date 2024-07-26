import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';

class BuyGiftVouchersBloc {
  BuyGiftVouchersBloc(this.repo);
  final GiftVoucherRepository repo;

  Stream<List<GiftVoucher>> get allGiftVouchers => repo.fetchAllToBuy();

  dispose() {}
}
