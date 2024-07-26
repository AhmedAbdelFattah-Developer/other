import 'gender.dart';

class TransactionUser {
  final String id;
  final String fName;
  final String lName;
  final Gender gender;
  final String statulsLabel;

  TransactionUser(
      this.id, this.fName, this.lName, this.gender, this.statulsLabel);

  TransactionUser.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        fName = data['fName'] ?? "",
        lName = data['lName'] ?? "",
        gender = Gender.fromApi(data['gender']),
        statulsLabel = data['status']['label'];

  String get fullname =>
      '${gender == null ? '' : gender.title + ' '}$fName $lName';
}
