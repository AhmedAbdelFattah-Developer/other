import 'flashsale.dart';
import 'item.dart';

class Catalog {
  final List<Flashsale> flashsales;
  final List<Item> items;
  final String shopId;

  Catalog({this.flashsales, this.items, this.shopId});
}