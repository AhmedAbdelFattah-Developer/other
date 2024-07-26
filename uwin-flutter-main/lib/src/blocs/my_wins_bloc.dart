import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:uwin_flutter/src/App.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/my_wins_menu_item.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';
import '../models/flashsale.dart';
import '../models/user.dart';
import '../models/coupon.dart';
import '../models/voucher.dart';
import 'auth_bloc.dart';

class MyWinsBloc {
  static const flashsalesEndpoint =
      'https://u-win.shop/admin/users/:id/flashSells';
  static const couponEndpoint = 'https://u-win.shop/admin/users/:id/coupons';
  static const voucherEndpoint = 'https://u-win.shop/admin/users/:id/vouchers';

  final AuthBloc authBloc;
  final _flashsales = PublishSubject<List<Flashsale>>();
  final _coupons = BehaviorSubject<List<Coupon>>();
  final _vouchers = BehaviorSubject<List<Voucher>>();
  final VoucherRepository voucherRepo;
  final GiftVoucherRepository giftVoucherRepo;

  MyWinsBloc(this.authBloc, this.voucherRepo, this.giftVoucherRepo);

  Stream<List<Flashsale>> get flashsales => _flashsales.stream;
  Stream<List<Coupon>> get coupons => _coupons.stream;
  Stream<List<Voucher>> get vouchers => _vouchers.stream;
  Stream<List<MyWinsMenuItem>> get menuItems => FirebaseFirestore.instance
      .collection('myWinMenuItems')
      .orderBy('position')
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => MyWinsMenuItem.fromMap(doc.data())).toList())
      .map((it) => it
          .where((item) => item.published || AppEnvironment().isStage)
          .toList());

  Stream<List<GiftVoucher>> get giftVoucher =>
      authBloc.user.switchMap((u) => giftVoucherRepo.fetchAllValid(u.id));

  // Stream<List<Voucher>> get vouchers =>
  //     Stream.combineLatest2<List<Voucher>, QuerySnapshot, List<Voucher>>(
  //       _vouchers.stream,
  //       Firestore.instance.collection('giftVouchers').snapshots(),
  //       (
  //         vouchers,
  //         giftVouchersSnaphot,
  //       ) {
  //         return <Voucher>[
  //           ...giftVouchersSnaphot.documents.map(
  //             (doc) => Voucher.firestoreGiftVoucher(doc.data),
  //           ),
  //           ...vouchers,
  //         ];
  //       },
  //     );

  fetch(String key) {
    switch (key) {
      case 'flashsales':
        fetchFlashsales();
        break;
      case 'my_coupons':
        fetchCoupons();
        break;
      case 'my_voucher':
        fetchVoucher();
        break;
    }
  }

  fetchFlashsales() async {
    authBloc.user.listen((User user) async {
      final client = new http.Client();
      final url = flashsalesEndpoint.replaceFirst(':id', user.id);

      try {
        var res = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': user.token,
          },
        );

        if (res.statusCode != 200) {
          _flashsales.addError("Could not find flashsells");

          return;
        }

        final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));
        _flashsales.sink.add(
          dataList.map((data) {
            return Flashsale.fromApi(data);
          }).toList(),
        );
      } finally {
        client.close();
      }
    });
  }

  fetchCoupons() {
    authBloc.user.listen((User user) async {
      final client = new http.Client();
      final url = couponEndpoint.replaceFirst(':id', user.id);

      try {
        var res = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': user.token,
          },
        );

        if (res.statusCode != 200) {
          _coupons.addError("Could not find coupons");

          return;
        }

        final List<dynamic> dataList = json.decode(utf8.decode(res.bodyBytes));
        _coupons.sink.add(
          dataList.map((data) {
            return Coupon.fromApi(data);
          }).toList(),
        );
      } finally {
        client.close();
      }
    });
  }

  fetchVoucher() {
    EasyDebounce.debounce(
      'fetchVoucher',
      Duration(milliseconds: 500),
      () async => await debounceFetchVoucher(),
    );
  }

  void resetVoucherSink() => _vouchers.sink.add(null);

  Future<void> debounceFetchVoucher() async {
    try {
      final user = await authBloc.user.take(1).first;
      final vouchers = await voucherRepo.fetchVoucher(user.token, user.id);
      _vouchers.sink.add(vouchers);
    } catch (err) {
      _vouchers.sink.addError(err);
    }
  }

  dispose() {
    _flashsales.close();
    _coupons.close();
    _vouchers.close();
  }
}
