import 'pos.dart';

class Shop {
  final String id;
  final String name;
  final String shopTypeId;
  final String shopTypeName;
  final String description;
  final List<String> photoPath;
  final String audience;
  final String state;
  final int updateTime;
  final String website;
  final List<Pos> posList;
  final _ShopStatusDiscount statusDiscount;

  Shop({
    this.id,
    this.name,
    this.shopTypeId,
    this.shopTypeName,
    this.description,
    this.photoPath,
    this.audience,
    this.state,
    this.updateTime,
    this.website,
    this.posList,
    this.statusDiscount,
  });

  Shop.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        shopTypeId = data['shopType']['id'],
        shopTypeName = data['shopType']['name'],
        description = data['description'],
        photoPath = data['photoPath'] == null
            ? []
            : List<String>.from(data['photoPath']),
        audience = data['audience'],
        state = data['state'],
        updateTime = data['updateTime'],
        website = data['website'],
        posList = [],
        statusDiscount = _ShopStatusDiscount.fromMap(data['statusDiscount']);

  double getDiscount(String level) {
    switch (level) {
      case 'Silver':
        return statusDiscount.silver;
      case 'Gold':
        return statusDiscount.gold;
      case 'Premium':
        return statusDiscount.premium;
      default:
        return 0.0;
    }
  }

  String get logoUrl {
    if (photoPath == null) {
      return null;
    }

    if (photoPath.length == 0) {
      return null;
    }

    if (photoPath.length == 1) {
      return photoPath.first;
    }

    return photoPath[1];
  }

  String get bannerUrl {
    if (photoPath == null) {
      return null;
    }

    if (photoPath.length == 0) {
      return null;
    }

    return photoPath.first;
  }

  bool get hasWebsite {
    return website != null && website.isNotEmpty;
  }

  bool _hasProtocol(String website) {
    RegExp exp = new RegExp(r"^http:\/\/|^https:\/\/");

    return exp.hasMatch(website);
  }

  String get websiteSafeUrl {
    if (!hasWebsite) {
      return '';
    }

    if (_hasProtocol(website)) {
      return website;
    }

    return 'http://$website';
  }
}

class _ShopStatusDiscount {
  final double premium;
  final double silver;
  final double gold;

  _ShopStatusDiscount({this.premium, this.gold, this.silver});

  _ShopStatusDiscount.fromMap(Map<String, dynamic> data)
      : premium = 0.0, //double.parse("${data['PREMIUM']}"),
        silver = 0.0, //double.parse("${data['SILVER']}"),
        gold = 0.0; //double.parse("${data['GOLD']}");
}
