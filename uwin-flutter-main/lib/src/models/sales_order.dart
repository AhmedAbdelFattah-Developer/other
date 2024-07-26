import 'package:uwin_flutter/src/models/item_ext.dart';
import 'package:uwin_flutter/src/models/shipping_details.dart';
import 'package:uwin_flutter/src/models/item.dart';
import 'package:uwin_flutter/src/models/voucher.dart';

class SalesOrder {
  SalesOrder(
    this.shopId,
    this._userId, {
    this.freeShippingEnabled = false,
    this.freeShippingThreshold = 0,
    this.handlingFeeEnabled = false,
    this.handlingFeeAmount = 0,
    this.noHandlingFeeEnabled = false,
    this.paymentState = '',
    this.noHandlingFeeThreshold = 0,
    this.model = 'default',
    String shippingLabel,
    Map<String, int> vouchers,
  })  : createdAt = DateTime.now().millisecondsSinceEpoch,
        _vouchers = vouchers ?? <String, int>{},
        _shippingLabel = shippingLabel,
        _items = <SalesOrderItem>[];

  SalesOrder.fromMap(Map<String, dynamic> data)
      : shopId = data['shopId'],
        createdAt = data['createdAt'],
        id = data['id'],
        freeShippingEnabled = data['freeShippingEnabled'],
        freeShippingThreshold = data['freeShippingThreshold'],
        handlingFeeEnabled = data['handlingFeeEnabled'],
        handlingFeeAmount = data['handlingFeeAmount'],
        noHandlingFeeEnabled = data['noHandlingFeeEnabled'],
        noHandlingFeeThreshold = data['noHandlingFeeThreshold'],
        paymentState = data['paymentState'] ?? '',
        _vouchers = data['vouchers'] != null
            ? Map<String, int>.from(data['vouchers'])
            : <String, int>{},
        _total = data['total'],
        _userId = data['userId'],
        _shippingLabel = data['shippingLabel'] ?? '',
        _shippingCost = data['shippingCost'] ?? 0,
        _shippingItemId = data['shippingItemId'] ?? '',
        _shippingShopId = data['shippingShopId'] ?? '',
        model = data['model'] ?? 'default',
        shippingDetails = data['shippingDetails'] == null
            ? null
            : ShippingDetails.fromMap(
                Map<String, dynamic>.from(data['shippingDetails'])),
        _items = List<Map<String, dynamic>>.from(
          List<Map<String, dynamic>>.from(
            data['items'].map((it) => Map<String, dynamic>.from(it)),
          ),
        ).map<SalesOrderItem>((d) => SalesOrderItem.fromMap(d)).toList();

  final String shopId;
  final int createdAt;
  List<SalesOrderItem> _items;
  String id;
  int _total = 0;
  ShippingDetails shippingDetails;
  String _shippingLabel;
  int _shippingCost = 0;
  String _shippingItemId;
  String _shippingShopId;
  String _userId;
  final Map<String, int> _vouchers;
  final String paymentState;
  final bool freeShippingEnabled;
  final int freeShippingThreshold;
  final bool handlingFeeEnabled;
  final int handlingFeeAmount;
  final bool noHandlingFeeEnabled;
  final int noHandlingFeeThreshold;
  final String model;

  Map<String, int> get vouchers => _vouchers;
  List<SalesOrderItem> get items => _items;

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'shopId': shopId,
      'userId': _userId,
      'createdAt': createdAt,
      'id': id,
      'total': _total,
      'shippingLabel': _shippingLabel,
      'shippingCost': shippingCost,
      'shippingItemId': _shippingItemId,
      'shippingShopId': _shippingShopId,
      'items': _items.map((it) => it.toMap).toList(),
      'shippingDetails': shippingDetails == null ? null : shippingDetails.toMap,
      'freeShippingEnabled': freeShippingEnabled,
      'freeShippingThreshold': freeShippingThreshold,
      'handlingFeeEnabled': handlingFeeEnabled,
      'handlingFeeAmount': handlingFeeAmount,
      'noHandlingFeeEnabled': noHandlingFeeEnabled,
      'noHandlingFeeThreshold': noHandlingFeeThreshold,
      'hasFreeShipping': hasFreeShipping,
      'vouchers': _vouchers,
      'model': model,
    };
  }

  int get total => _total;

  updateTotal() {
    for (final it in _items) {
      it.updateTotal();
    }

    _total = _items.fold<int>(0, (sum, it) => sum + it.total) + shippingCost;

    if (hasHandlingFee) {
      _total += handlingFeeAmount;
    }

    if (_vouchers.length > 0) {
      final vouchersAmt = voucherAmount;
      _total = vouchersAmt < _total ? _total - vouchersAmt : 0;
    }
  }

  bool get hasVoucher => _vouchers.length > 0;

  int get voucherAmount =>
      _vouchers.values.fold<int>(0, (acc, v) => acc + v) * 100;

  addItem(Item prod) {
    items.add(
      SalesOrderItem(
        prod,
        prod.name,
        prod.description == null ? null : prod.description.trim(),
        prod.photoPath,
        0,
        (prod.price * 100).round(),
        0,
      ),
    );
  }

  void pruneItems() {
    _items = _items
        .where(
          (it) => it.quantity > 0,
        )
        .toList();

    _items.forEach((it) => it.prune());
  }

  bool canAddQuantity(Item prod, {int stepper = 1}) {
    for (final it in items) {
      if (it.product.id == prod.id) {
        return it.canAddQuantity(stepper: stepper);
      }
    }

    throw 'Could not find product';
  }

  void addQuantity(Item prod, {int stepper = 1}) {
    if (prod.ext == null) {
      throw Exception('Product Extension cannot be null');
    }

    if (!canAddQuantity(prod, stepper: stepper)) {
      return;
    }

    for (final it in items) {
      if (it.product.id == prod.id) {
        it.addQuantity(stepper: stepper);
        updateTotal();

        return;
      }
    }

    throw 'Could not find product';
  }

  String get shippingLabel => _shippingLabel;
  String get shippingItemId => _shippingItemId;
  String get shippingShopId => _shippingShopId;
  int get shippingCost => hasFreeShipping ? 0 : _shippingCost;
  String get userId => _userId;

  set shipping(Item it) {
    _shippingCost = it.priceCurrency;
    _shippingItemId = it.id;
    _shippingLabel = it.name;
    _shippingShopId = it.shopId;

    updateTotal();
  }

  List<SalesOrderItem> get orderedItems =>
      items.where((it) => it.quantity > 0).toList();

  int get itemsTotal => _items.fold<int>(0, (sum, it) => sum + it.total);

  bool get hasHandlingFee =>
      handlingFeeEnabled &&
      itemsTotal > 0 &&
      ((!noHandlingFeeEnabled || itemsTotal < noHandlingFeeThreshold));

  bool get hasFreeShipping =>
      freeShippingEnabled && (itemsTotal > freeShippingThreshold);

  List<String> get categories {
    final map = <String, bool>{};

    for (final it in _items) {
      final itExt = it.product.ext ?? ItemExt();
      final cat1 = itExt.category1;
      final cat2 = itExt.category2;
      if (cat1 == 'Gift Vouchers' || cat2 == 'Gift Vouchers') {
        continue;
      }
      map[cat1] = true;

      if (cat2.isNotEmpty) {
        map[cat2] = true;
      }
    }
    final cats = List<String>.from(map.keys);
    cats.sort((a, b) {
      if (a.isEmpty) {
        return 1;
      }
      if (b.isEmpty) {
        return -1;
      }

      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return cats;
  }

  List<SalesOrderItem> filteredItems(String cat) {
    return _items.where((it) => it.product.hasCategory(cat)).toList();
  }

  Map<String, List<SalesOrderItem>> groupBySubcategory(String cat) {
    final map = <String, List<SalesOrderItem>>{};
    for (final it in _items) {
      if (it.product.ext == null) {
        continue;
      }

      if (it.product.ext.category1 == cat) {
        if (map[it.product.ext.subcategory1] == null) {
          map[it.product.ext.subcategory1] = <SalesOrderItem>[];
        }
        map[it.product.ext.subcategory1].add(it);
      }

      if (it.product.ext.category2.isEmpty) {
        continue;
      }

      if (it.product.ext.category2 == cat) {
        if (map[it.product.ext.subcategory2] == null) {
          map[it.product.ext.subcategory2] = <SalesOrderItem>[];
        }
        map[it.product.ext.subcategory2].add(it);
      }
    }

    return map;
  }

  void toggleVoucher(Voucher voucher) {
    if (_vouchers.containsKey(voucher.id)) {
      _vouchers.remove(voucher.id);
    } else {
      _vouchers[voucher.id] = voucher.amount;
    }

    updateTotal();
  }
}

class SalesOrderItem {
  String _productId;
  Item _product;
  String _label;
  String _details;
  String _photoPath;
  int _quantity;
  int _unitPrice;
  int _total;

  SalesOrderItem(
    this._product,
    this._label,
    this._details,
    this._photoPath,
    this._quantity,
    this._unitPrice,
    this._total,
  ) : _productId = _product.id;

  SalesOrderItem.fromMap(Map<String, dynamic> data)
      : _productId = data['productId'],
        _product = Item.fromApi(Map<String, dynamic>.from(data['product'])),
        _label = data['label'],
        _details = data['details'],
        _photoPath = data['photoPath'],
        _quantity = data['quantity'],
        _unitPrice = data['unitPrice'],
        _total = data['total'];

  Map<String, dynamic> get toMap => <String, dynamic>{
        'productId': _productId,
        'product': _product == null ? null : _product.toMap,
        'label': _label,
        'details': _details,
        'photoPath': _photoPath,
        'quantity': _quantity,
        'unitPrice': _unitPrice,
        'total': _total,
      };

  Item get product => _product;
  String get label => _label;
  String get photoPath => _photoPath;
  int get quantity => _quantity;
  int get unitPrice => _unitPrice;
  int get total => _total;
  String get details => _details;
  String get productId => _productId;

  updateTotal() {
    _total = _quantity * _unitPrice;
  }

  bool canAddQuantity({int stepper = 1}) {
    return product.ext.quantityAvailable >= quantity + stepper;
  }

  void addQuantity({int stepper = 1}) {
    if (_quantity + stepper < 0) {
      return;
    }

    _quantity += stepper;
    updateTotal();
  }

  bool get hasDetails => _details != null && _details.isNotEmpty;
  bool get isAvailable => product.ext.quantityAvailable > 0;

  void prune() {
    _details = null;
    _product = null;
  }
}
