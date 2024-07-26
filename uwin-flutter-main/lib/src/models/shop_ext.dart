import 'package:uwin_flutter/src/models/shop.dart';

class ShopExt {
  final String id;
  final bool adult;
  final String brn;
  final String plan;
  final String tradeName;
  final String vatNumber;
  final String loyaltyShopId;
  final bool freeShippingEnabled;
  final int freeShippingThreshold;
  final bool handlingFeeEnabled;
  final int handlingFeeAmount;
  final bool noHandlingFeeEnabled;
  final int noHandlingFeeThreshold;
  final Map<String, bool> logisticProviders;
  final bool onlineCatalogButton;
  final bool catalogButton;
  final bool buyNowButton;
  final bool giftVoucherButton;
  final bool isFeatured;
  final List<TabData> tabs;

  ShopExt({
    this.id,
    this.adult = false,
    this.brn = '',
    this.plan = 'STARTER',
    this.tradeName,
    this.vatNumber,
    this.loyaltyShopId,
    this.freeShippingEnabled = false,
    this.freeShippingThreshold = 0,
    this.handlingFeeEnabled = false,
    this.handlingFeeAmount = 0,
    this.noHandlingFeeEnabled = false,
    this.noHandlingFeeThreshold = 0,
    this.onlineCatalogButton,
    this.catalogButton,
    this.buyNowButton,
    this.giftVoucherButton,
    this.isFeatured,
    this.tabs,
    logisticProviderList,
  }) : logisticProviders = logisticProviderList ?? Map<String, bool>();

  ShopExt.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        adult = data['adult'] ?? false,
        brn = data['brn'] ?? '',
        plan = data['plan'] ?? 'STARTER',
        tradeName = data['tradeName'] ?? '',
        vatNumber = data['vatNumber'] ?? '',
        loyaltyShopId = data['loyaltyShopId'] ?? null,
        logisticProviders = data['logisticProviders'] != null
            ? Map<String, bool>.from(data['logisticProviders'])
            : <String, bool>{},
        freeShippingEnabled = data['freeShippingEnabled'] ?? false,
        freeShippingThreshold = data['freeShippingThreshold'] ?? 0,
        handlingFeeEnabled = data['handlingFeeEnabled'] ?? false,
        handlingFeeAmount = data['handlingFeeAmount'] ?? 0,
        noHandlingFeeEnabled = data['noHandlingFeeEnabled'] ?? false,
        noHandlingFeeThreshold = data['noHandlingFeeThreshold'] ?? 0,
        onlineCatalogButton = data['onlineCatalogButton'] ?? false,
        catalogButton = data['catalogButton'] ?? false,
        buyNowButton = data['buyNowButton'] ?? false,
        giftVoucherButton = data['giftVoucherButton'] ?? false,
        isFeatured = data['isFeatured'] ?? false,
        tabs = _initTabs(data['tabs']);
}

class ShopShopExt {
  final Shop shop;
  final ShopExt ext;

  ShopShopExt({this.ext, this.shop});
}

class TabData {
  final String label;
  final String url;

  TabData.fromMap(Map<String, dynamic> data)
      : label = data['label'],
        url = data['content'];

  TabData({this.label, this.url});
}

List<TabData> _initTabs(List<dynamic> list) {
  if (list == null) {
    return <TabData>[];
  }

  return list.map((data) => TabData.fromMap(data)).toList();
}
