import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/repositories/voucher_repository.dart';
import 'package:uwin_flutter/src/repositories/sales_order_repository.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/models/item.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/models/shop_ext.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/models/user.dart';
import 'package:uwin_flutter/src/repositories/item_repository.dart';
import 'package:uwin_flutter/src/repositories/shop_repository.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';

class CheckoutStep {
  final String name;

  const CheckoutStep({this.name});
}

class CheckoutSteps {
  static const items = CheckoutStep(name: 'item-selection');
  static const delivery = CheckoutStep(name: 'delivery');
}

class CheckoutBloc {
  CheckoutBloc({
    @required this.authBloc,
    @required this.itemRepo,
    @required this.shopRepo,
    @required this.soRepo,
    @required this.voucherRepo,
  });

  final _shopId = BehaviorSubject<String>();
  final _salesOrder = BehaviorSubject<SalesOrder>();
  final _items = BehaviorSubject<List<Item>>();
  final _shipping = BehaviorSubject<Item>();
  final _logisticProvidersItems = BehaviorSubject<List<Item>>();
  final _currentCategory = BehaviorSubject<String>();
  final _vouchers = BehaviorSubject<Map<String, Voucher>>();
  final _step = BehaviorSubject.seeded(CheckoutSteps.items);
  final _itemsDetails = BehaviorSubject<Map<String, bool>>();
  final AuthBloc authBloc;
  final ItemRepository itemRepo;
  final ShopRepository shopRepo;
  final SalesOrderRepository soRepo;
  final VoucherRepository voucherRepo;
  Stream<String> get currentCategory => _currentCategory.stream;
  void Function(String) get changeCategory => _currentCategory.sink.add;
  void Function(CheckoutStep) get changeStep => _step.sink.add;
  Stream<CheckoutStep> get step => _step.stream;
  Stream<Map<String, Voucher>> get vouchers => _vouchers.stream;

  init(String shopId) {
    _itemsDetails.sink.add(null);
    _items.sink.add(null);
    _salesOrder.sink.add(null);
    _currentCategory.sink.add(null);
    _shopId.sink.add(shopId);
    _shipping.sink.add(Item());
    _vouchers.sink.add(null);
    changeStep(CheckoutSteps.items);
    authBloc.user.take(1).listen(
      (u) async {
        try {
          final vouchers = await voucherRepo.fetchVoucherByShop(
            u.token,
            u.id,
            shopId,
          );
          _vouchers.sink.add(
            Map<String, Voucher>.fromEntries(
              vouchers.map((v) => MapEntry(v.id, v)),
            ),
          );
        } catch (err) {
          print('[checkout_bloc] $err');
          _vouchers.sink.addError('Coud not find vouchers');
        }

        Rx.combineLatest3<List<Item>, ShopExt, Map<String, Voucher>,
            SalesOrder>(
          itemRepo.fetchPublishByShop(shopId, u.token).take(1),
          shopRepo.fetchExt(shopId).take(1),
          vouchers,
          (its, se, vouchers) {
            final so = SalesOrder(
              se.id,
              u.id,
              freeShippingEnabled: se.freeShippingEnabled,
              freeShippingThreshold: se.freeShippingThreshold,
              handlingFeeAmount: se.handlingFeeAmount,
              handlingFeeEnabled: se.handlingFeeEnabled,
              noHandlingFeeEnabled: se.noHandlingFeeEnabled,
              noHandlingFeeThreshold: se.noHandlingFeeThreshold,
            );

            for (final it in its) {
              so.addItem(it);
            }
            so.updateTotal();

            return so;
          },
        ).take(1).listen((so) {
          final cats = so.categories;
          if (cats.length > 0) {
            _currentCategory.sink.add(cats.first);
          }
          _salesOrder.sink.add(so);
          _itemsDetails.sink.add(
            Map<String, bool>.fromEntries(
                so.items.map((it) => MapEntry(it.productId, false))),
          );
        });

        Rx.combineLatest2<List<Item>, ShopExt, List<Item>>(
          _allLogisticProvidersItems,
          shopRepo.fetchExt(shopId),
          (spList, shopExt) => spList
              .where((it) => shopExt.logisticProviders[it.shopId] == true)
              .toList(),
        ).take(1).listen((lpits) => _logisticProvidersItems.sink.add(lpits));
      },
    );
  }

  Stream<Map<Item, bool>> get logisticProvidersItemsMap =>
      Rx.combineLatest2<List<Item>, Item, Map<Item, bool>>(
          logisticProvidersItems, _shipping.stream, (itemsVal, itemVal) {
        final map = <Item, bool>{};
        for (var it in itemsVal) {
          map[it] = it.id == itemVal.id;
        }

        return map;
      });

  Stream<List<Item>> get logisticProvidersItems =>
      _logisticProvidersItems.stream;

  Stream<List<Item>> get _allLogisticProvidersItems => authBloc.user.switchMap(
        (u) => itemRepo.fetchAllLogisticProviderItems(
          u.id,
          u.token,
        ),
      );

  Stream<Shop> get shop =>
      Rx.combineLatest2<User, String, Map<String, dynamic>>(
        authBloc.user,
        _shopId.stream,
        (u, sId) => <String, dynamic>{'token': u.token, 'shopId': sId},
      ).asBroadcastStream().switchMap(
            (req) => shopRepo
                .fetch(req['token'], req['shopId'])
                .asStream()
                .asBroadcastStream(),
          );

  Stream<SalesOrder> get salesOrder => _salesOrder.stream;
  Stream<Map<String, bool>> get itemsDetails => _itemsDetails.stream;

  void toggleItemsDetail(Map<String, bool> items, String itemId) {
    items[itemId] = !items[itemId];
    _itemsDetails.sink.add(items);
  }

  void increment(Item prod) {
    final so = _salesOrder.value;
    so.addQuantity(prod);

    _salesOrder.sink.add(so);
  }

  void decrement(Item prod) {
    final so = _salesOrder.value;
    so.addQuantity(prod, stepper: -1);

    _salesOrder.sink.add(so);
  }

  Future<SalesOrder> checkout(SalesOrder salesOrder) async {
    return soRepo.save(salesOrder);
  }

  void setShipping(Item it) {
    final so = _salesOrder.value;
    so.shipping = it;

    _shipping.sink.add(it);
    _salesOrder.sink.add(so);
  }

  bool isValid(SalesOrder so, CheckoutStep step) {
    return so.itemsTotal > 0 &&
        (so.hasFreeShipping ||
            (step == CheckoutSteps.delivery && so.shippingShopId != null));
  }

  void toggleVoucher(Voucher voucher) {
    final so = _salesOrder.value;
    so.toggleVoucher(voucher);

    _salesOrder.sink.add(so);
  }

  void dispose() {
    _itemsDetails.close();
    _vouchers.close();
    _shopId.close();
    _salesOrder.close();
    _items.close();
    _shipping.close();
    _logisticProvidersItems.close();
    _currentCategory.close();
    _step.close();
  }
}
