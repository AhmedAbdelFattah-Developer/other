import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/providers/my_wins_bloc_provider.dart';
import 'package:uwin_flutter/src/models/coupon.dart';
import 'package:uwin_flutter/src/models/flashsale.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/user.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/repositories/coupon_repository.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/transaction_repository.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';

import '../blocs/auth_bloc.dart';
import '../models/flashsale.dart';
import '../models/shop.dart';
import '../models/transaction.dart';
import '../models/transaction_user.dart';
import '../repositories/shop_repository.dart';
import '../repositories/user_repository.dart';

class _UserShop {
  final User user;
  final Shop shop;
  _UserShop({this.user, this.shop});
}

class ShopTransactionBloc {
  final AuthBloc authBloc;
  final _shop = BehaviorSubject<Shop>();
  final _user = BehaviorSubject<String>();
  final _flashSales = BehaviorSubject<List<Flashsale>>();
  final _showVoucherButtonSpinner = BehaviorSubject<bool>();
  final _selectedFlashsale = BehaviorSubject<Map<String, int>>();
  final _allVouchers = BehaviorSubject<List<Voucher>>();
  final _voucherList = BehaviorSubject<List<Voucher>>();
  final _giftVoucherList = BehaviorSubject<List<GiftVoucher>>();
  final _showCouponButtonSpinner = BehaviorSubject<bool>();
  final _couponList = BehaviorSubject<List<Coupon>>();
  final _transactionTotal = BehaviorSubject<double>();
  final _discountEnabled = BehaviorSubject<bool>();
  final _showSubmitSpinner = BehaviorSubject<bool>();
  final UserRepository userRepo;
  final ShopRepository shopRepo;
  final VoucherRepository voucherRepo;
  final CouponRepository couponRepo;
  final TransactionRepository transactionRepo;
  final GiftVoucherRepository giftVoucherRepo;
  final _geolocation = BehaviorSubject<String>();

  double _discount = 0.0;
  double _transDiscount = 0.0;

  ShopTransactionBloc({
    @required this.authBloc,
    @required this.userRepo,
    @required this.shopRepo,
    @required this.voucherRepo,
    @required this.giftVoucherRepo,
    @required this.couponRepo,
    @required this.transactionRepo,
  });

  Stream<Shop> get shop => _shop.stream;

  fetch(String shopId, String geolocation) async {
    try {
      _flashSales.sink.add(null);
      _user.sink.add(authBloc.currentUser.id);
      _selectedFlashsale.sink.add(<String, int>{});
      _allVouchers.sink.add(null);
      _voucherList.sink.add(<Voucher>[]);
      _giftVoucherList.sink.add(<GiftVoucher>[]);
      _couponList.sink.add(<Coupon>[]);
      _discountEnabled.sink.add(true);
      _transactionTotal.sink.add(0);
      _showSubmitSpinner.sink.add(false);
      final shop = await shopRepo.fetch(authBloc.currentUser.token, shopId);
      _shop.sink.add(shop);
      _geolocation.add(geolocation);
    } catch (err) {
      _shop.sink.addError('Could not find shop');
    }

    try {
      final flashSales =
          await shopRepo.fetchFlashSales(authBloc.currentUser.token, shopId);
      _flashSales.sink.add(flashSales);
    } catch (err) {
      print('[shop_transaction_bloc] $err');
      _flashSales.sink
          .addError('could not get list of flash sale for this shop');
    }

    try {
      _allVouchers.sink.add(await fetchVoucherList());
    } catch (err) {
      print('Could not fetch voucher list: $err');

      _allVouchers.sink.addError('Could not fetch voucher list');
    }
  }

  Stream<bool> get discountEnabled => _discountEnabled.stream;
  Stream<double> get transactionTotal => _transactionTotal.stream;
  Stream<bool> get showVoucherButtonSpinner => _showVoucherButtonSpinner.stream;
  Stream<bool> get showCouponButtonSpinner => _showCouponButtonSpinner.stream;
  Stream<double> get totalFlashsales =>
      Rx.combineLatest2<List<Flashsale>, Map<String, int>, double>(
        flashSales,
        _selectedFlashsale.stream,
        (fss, sfss) {
          return fss.where((fs) => sfss[fs.id] != null).fold<double>(
                0.0,
                (acc, fs) => acc + fs.discountValue * sfss[fs.id],
              );
        },
      );

  Stream<double> get totalVoucher => _voucherList.transform(
        StreamTransformer.fromHandlers(
          handleData: (value, sink) {
            sink.add(value.fold(0.0, (acc, v) => acc + v.amount));
          },
        ),
      );

  Stream<int> get totalGiftVoucher => _giftVoucherList.transform(
        StreamTransformer.fromHandlers(
          handleData: (value, sink) {
            sink.add(value.fold(0, (acc, v) => acc + v.amount));
          },
        ),
      );

  Stream<double> get totalCoupon => _couponList.transform(
        StreamTransformer.fromHandlers(
          handleData: (value, sink) {
            sink.add(value.fold(0.0, (acc, c) => acc + c.discountValue));
          },
        ),
      );

  Stream<TransactionUser> get user => _user.stream.transform(
        StreamTransformer.fromHandlers(handleData: (userId, sink) async {
          try {
            sink.add(await userRepo.fetch(authBloc.currentUser.token, userId));
          } catch (err) {
            print(
                '[shop_transaction_bloc] Could not fetch user data. Error: $err');
            _user.sink.addError(err);
          }
        }, handleError: (obj, errStack, sink) {
          sink.addError('could not find user data');
        }),
      );

  Stream<ShopTransaction> get shopTransaction =>
      Rx.combineLatest2(user, shop, (user, shop) {
        return ShopTransaction(shop: shop, user: user);
      });

  Stream<List<Flashsale>> get flashSales => _flashSales.stream;

  Stream<int> selectedFlashsale(String flashSaleId) =>
      _selectedFlashsale.transform(
        StreamTransformer.fromHandlers(handleData: (selected, sink) {
          sink.add(selected[flashSaleId]);
        }, handleError: (selected, stack, sink) {
          print('[shop_transaction_bloc] selected err. $stack.');
        }),
      );

  Stream<List<Voucher>> get allVoucherList => _allVouchers.stream;
  Stream<List<Voucher>> get voucherList => _voucherList.stream;
  Stream<List<Coupon>> get couponList => _couponList.stream;
  Stream<List<GiftVoucher>> get allGiftVoucherList => Rx.combineLatest2(
        authBloc.user,
        shop,
        (u, sh) => (_UserShop(user: u, shop: sh)),
      ).switchMap(
        (userShop) => giftVoucherRepo.fetchAllValidByShop(
            userShop.user.id, userShop.shop.id),
      );
  Stream<List<GiftVoucher>> get giftVoucherList => _giftVoucherList.stream;

  Stream<double> get discount =>
      Rx.combineLatest4<bool, double, TransactionUser, Shop, double>(
        discountEnabled,
        _transactionTotal.stream,
        user,
        shop,
        (discount, total, user, shop) {
          if (!discount) {
            return 0.0;
          }
          final rate = shop.getDiscount(user.statulsLabel) / 100;
          _discount = total * rate;

          return _discount;
        },
      );

  Stream<double> get total => Rx.combineLatest7<double, double, double, int,
          double, double, bool, double>(
        transactionTotal,
        totalFlashsales,
        totalVoucher,
        totalGiftVoucher,
        totalCoupon,
        discount,
        discountEnabled,
        (transtot, ftot, vtot, gvtot, ctot, disctot, discEnabled) {
          final tot = transtot -
              ftot -
              vtot -
              (gvtot / 100) -
              ctot -
              (discEnabled ? disctot : 0.0);
          _transDiscount = _transactionTotal.value - tot;

          return tot > 0 ? tot : 0;
        },
      );

  Stream<bool> get formValid => transactionTotal.transform(
        StreamTransformer.fromHandlers(
          handleData: (total, sink) {
            sink.add(total > 0);
          },
          handleError: (total, errorStack, sink) {
            sink.add(false);
          },
        ),
      );

  Stream<SubmitButtonState> get submitBtnState =>
      Rx.combineLatest2<double, bool, SubmitButtonState>(
        _transactionTotal.stream,
        _showSubmitSpinner.stream,
        (tot, show) {
          if (show) {
            return SubmitButtonStates.spinner;
          }

          if (tot > 0.0) {
            return SubmitButtonStates.enabled;
          } else {
            return SubmitButtonStates.disabled;
          }
        },
      );

  toggleDiscount() {
    final data = _discountEnabled.value;
    _discountEnabled.sink.add(!data);
  }

  changeFlashSaleQuantity(Flashsale flashSale, int quantity) {
    final data = _selectedFlashsale.value;
    data[flashSale.id] = quantity;
    _selectedFlashsale.sink.add(data);
  }

  int getFlashSaleQuantity(Flashsale flashSale) {
    final data = _selectedFlashsale.value;

    return data[flashSale.id] ?? 0;
  }

  addVoucher(Voucher voucher) {
    final data = _voucherList.value;

    // Ignore duplicates
    if (data.indexWhere((v) => v.id == voucher.id) != -1) {
      return;
    }

    data.add(voucher);
    _voucherList.sink.add(data);
  }

  removeVoucher(Voucher voucher) {
    final data = _voucherList.value;
    data.removeWhere((v) => v.id == voucher.id);

    _voucherList.sink.add(data);
  }

  Future<List<Voucher>> fetchVoucherList() async {
    _showVoucherButtonSpinner.sink.add(true);
    try {
      final voucher = await voucherRepo.fetchVoucher(
          authBloc.currentUser.token, _user.value);
      return voucher.where((v) => v.shopId == _shop.value.id).toList()
        ..sort((b, a) => a.amount.compareTo(b.amount));
    } finally {
      _showVoucherButtonSpinner.sink.add(false);
    }
  }

  Future<List<Coupon>> fetchCouponList() async {
    _showCouponButtonSpinner.sink.add(true);
    try {
      final coupons =
          await couponRepo.fetchCoupon(authBloc.currentUser.token, _user.value);

      return coupons.where((c) => c.shopId == _shop.value.id).toList()
        ..sort((a, b) => a.itemName.compareTo(b.itemName));
    } finally {
      _showCouponButtonSpinner.sink.add(false);
    }
  }

  addCoupon(Coupon coupon) {
    final data = _couponList.value;

    // Ignore duplicates
    if (data.indexWhere((c) => c.id == coupon.id) != -1) {
      return;
    }

    data.add(coupon);
    _couponList.sink.add(data);
  }

  removeCoupon(Coupon coupon) {
    final data = _couponList.value;
    data.removeWhere((c) => c.id == coupon.id);

    _couponList.sink.add(data);
  }

  updateTransactionTotal(String value) {
    if (value == null || value.trim().length == 0) {
      _transactionTotal.sink.add(0.0);
    }

    try {
      _transactionTotal.sink.add(double.parse(value));
    } catch (err) {
      _transactionTotal.sink.addError('Invalid');
    }
  }

  Future<Map<String, VoucherCode>> submit(MyWinsBloc myWinsBloc) async {
    _showSubmitSpinner.sink.add(true);
    final vouchersIdWithCode = _voucherList.value
        .where((voucher) => voucher.useVoucherCode)
        .map((voucher) => voucher.id)
        .toList();
    print('_geolocation.value: ${_geolocation.value}');
    final trans = Transaction(
      geolocation: _geolocation.value,
      transDiscount: _transDiscount,
      discountAmount: _discount,
      transTotal: _transactionTotal.value,
      discounted: _discountEnabled.value,
      coupons: _couponList.value.map((c) => c.id).toList(),
      vouchers: _voucherList.value.map((v) => v.id).toList(),
      giftVouchers: _giftVoucherList.value.map((gv) => gv.id).toList(),
      flashsales: _flashSales.value
          .where((f) =>
              _selectedFlashsale.value[f.id] != null &&
              _selectedFlashsale.value[f.id] > 0)
          .map(
            (f) => TransactionFlashSale(
              id: f.id,
              remainingNbSales:
                  f.remainingNbSales - _selectedFlashsale.value[f.id],
            ),
          )
          .toList(),
    );

    try {
      final codes = await transactionRepo.record(
        _shop.value.id,
        _user.value,
        trans,
        vouchersIdWithCode,
      );
      myWinsBloc.resetVoucherSink();
      myWinsBloc.debounceFetchVoucher();

      return codes;
    } finally {
      _showSubmitSpinner.sink.add(false);
    }
  }

  bool isVoucherSelected(Voucher voucher, List<Voucher> list) {
    for (var v in list) {
      if (v.id == voucher.id) {
        return true;
      }
    }

    return false;
  }

  dispose() {
    _user.close();
    _shop.close();
    _flashSales.close();
    _selectedFlashsale.close();
    _voucherList.close();
    _giftVoucherList.close();
    _couponList.close();
    _showVoucherButtonSpinner.close();
    _showCouponButtonSpinner.close();
    _transactionTotal.close();
    _discountEnabled.close();
    _allVouchers.close();
    _showSubmitSpinner.close();
    _geolocation.close();
  }

  isGiftVoucherSelected(GiftVoucher gv, List<GiftVoucher> list) {
    for (var v in list) {
      if (v.id == gv.id) {
        return true;
      }
    }

    return false;
  }

  void addGiftVoucher(GiftVoucher giftVoucher) {
    final data = _giftVoucherList.value;

    // Ignore duplicates
    if (data.indexWhere((v) => v.id == giftVoucher.id) != -1) {
      return;
    }

    data.add(giftVoucher);
    _giftVoucherList.sink.add(data);
  }

  void removeGiftVoucher(GiftVoucher giftVoucher) {
    final data = _giftVoucherList.value;
    data.removeWhere((v) => v.id == giftVoucher.id);

    _giftVoucherList.sink.add(data);
  }

  Future<bool> hasGiftVouher() async {
    return _giftVoucherList.value.length > 0;
  }

  Future<bool> hasVouher() async {
    return _voucherList.value.length > 0;
  }
}

class SubmitButtonState {
  final String name;

  const SubmitButtonState({this.name});
}

class SubmitButtonStates {
  static const enabled = SubmitButtonState(name: 'enabled');
  static const disabled = SubmitButtonState(name: 'disabled');
  static const spinner = SubmitButtonState(name: 'spinner');
}

class ShopTransaction {
  final TransactionUser user;
  final Shop shop;

  ShopTransaction({this.shop, this.user});
}
