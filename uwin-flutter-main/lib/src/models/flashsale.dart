class Flashsale {
  final String type;
  final String id;
  final String idItem;
  final String name;
  final String photoPath;
  final String description;
  final double discountValue;
  final bool running;
  final String state;
  final String nameItem;
  final double priceItem;
  final String photoPathItem;
  final int frequencyId;
  final int frequencyMaxSales;
  final int remainingNbSales;
  final String idShop;
  final String nameShop;
  final int usedDate;
  final int discountPercent;
  final double discountedItemPrice;

  Flashsale({
    this.type,
    this.id,
    this.idItem,
    this.name,
    this.photoPath,
    this.description,
    this.discountValue,
    this.running,
    this.state,
    this.nameItem,
    this.priceItem,
    this.photoPathItem,
    this.frequencyId,
    this.frequencyMaxSales,
    this.remainingNbSales,
    this.idShop,
    this.nameShop,
    this.usedDate,
    this.discountedItemPrice,
  }) : this.discountPercent = 0;

  Flashsale.fromApi(Map<String, dynamic> data)
      : type = data['type'],
        id = data['id'],
        idItem = data['idItem'],
        name = data['name'],
        photoPath = data['photoPath'],
        description = data['description'],
        discountValue = data['discountValue'],
        running = data['running'],
        state = data['state'],
        nameItem = data['nameItem'],
        priceItem = data['priceItem'],
        photoPathItem = data['photoPathItem'],
        frequencyId = data['frequencyId'],
        frequencyMaxSales = data['frequencyMaxSales'],
        remainingNbSales = data['remainingNbSales'],
        idShop = data['idShop'],
        nameShop = data['nameShop'],
        usedDate = data['usedDate'],
        discountedItemPrice = data['priceItem'] - data['discountValue'],
        discountPercent = data['priceItem'] > 0 ? (data['discountValue']*100/data['priceItem']).round() : 0;
}
