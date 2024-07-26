import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/shop_repository.dart';

class ShopVoucherSuccessBloc {
  ShopVoucherSuccessBloc(this.authBloc, this.shopRepo, this.giftVoucherRepo);
  final ShopRepository shopRepo;
  final GiftVoucherRepository giftVoucherRepo;
  final AuthBloc authBloc;

  Stream<Shop> getShop(String shopId) => authBloc.user.asyncMap(
        (u) => shopRepo.fetch(u.token, shopId),
      );

  Stream<GiftVoucher> getGiftVoucher(String salesOrderId) =>
      authBloc.user.switchMap(
          (u) => giftVoucherRepo.fetchFromSalesOrder(u.id, salesOrderId));
}
