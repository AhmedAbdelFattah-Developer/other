class OtherCard {
  final String id;
  final String uid;
  final String label;
  final String number;
  final String frontPath;
  final String backPath;

  OtherCard({
    this.id,
    this.uid,
    this.label,
    this.number,
    this.frontPath,
    this.backPath,
  });

  OtherCard.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        uid = data['uid'],
        label = data['label'],
        number = data['number'],
        frontPath = data[CardSides.front.field] ?? '',
        backPath = data[CardSides.back.field] ?? '';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'label': label,
      'number': number,
      CardSides.front.field: frontPath,
      CardSides.back.field: backPath,
    };
  }

  String getPath(CardSide cardSide) {
    switch (cardSide) {
      case CardSides.front:
        return frontPath;
      case CardSides.back:
        return backPath;
      default:
        return "";
    }
  }
}

class CardSide {
  final String side;
  final String filename;
  final String field;

  const CardSide(this.side, this.filename, this.field);
}

class CardSides {
  static const front = CardSide('front', 'other_card_front', 'frontImagePath');
  static const back = CardSide('back', 'other_card_back', 'backImagePath');
}
