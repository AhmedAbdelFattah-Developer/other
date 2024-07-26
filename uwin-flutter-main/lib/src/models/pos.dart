import 'shop.dart';

class Pos {
  final String id;
  final String name;
  final String cityId;
  final String cityName;
  final String cityDistrict;
  final String tel;
  final String address;
  final double lng;
  final double lat;
  final String description;
  final List<String> photoPath;
  final String website;
  final int creationTime;
  final int updateTime;
  final bool favorite;
  final int order;
  final Shop shop;

  Pos.fromApi(Map<String, dynamic> data) 
      : id = data['id'],
        name = data['name'],
        cityId = data['city']['id'],
        cityName = data['city']['name'],
        cityDistrict = data['cityDistrict'],
        tel = data['tel'],
        address = data['address'],
        lng = data['lng'],
        lat = data['lat'],
        description = data['description'],
        photoPath = data['photoPath'] == null ? [] : List<String>.from(data['photoPath']),
        website = data['website'],
        creationTime = data['creationTime'],
        updateTime = data['updateTime'],
        favorite = data['favorite'],
        order = data['order'],
        shop = data['shop'] == null ? null : Shop.fromApi(data['shop']);
}
