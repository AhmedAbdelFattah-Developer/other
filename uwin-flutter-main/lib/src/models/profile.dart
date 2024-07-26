class Profile {
  final String id;
  final String cityId;
  final String cityName;
  final String cityDistrict;
  final String fName;
  final String lName;
  final String address;
  final String tel;
  final String mobile;
  final String email;
  final String pwd;
  final String statulsLabel;
  final int statulsId;
  final int statusValidityDate;
  final String loc;
  final int lastLoginDate;
  final int genderId;
  final String genderLabel;
  final int occupationId;
  final String occupationLabel;
  final int educationId;
  final String educationLabel;
  final String maritalStatusLabel;
  final int maritalStatusId;
  final int dateOfBirth;
  final int nbChildren;
  final String transportationLabel;
  final int transportationId;
  final bool profileCompleted;

  const Profile({
    this.id,
    this.cityId,
    this.cityName,
    this.cityDistrict,
    this.fName,
    this.lName,
    this.address,
    this.tel,
    this.mobile,
    this.email,
    this.pwd,
    this.statulsLabel,
    this.statulsId,
    this.statusValidityDate,
    this.loc,
    this.lastLoginDate,
    this.genderId,
    this.genderLabel,
    this.occupationId,
    this.occupationLabel,
    this.educationId,
    this.educationLabel,
    this.maritalStatusLabel,
    this.maritalStatusId,
    this.dateOfBirth,
    this.nbChildren,
    this.transportationLabel,
    this.transportationId,
    this.profileCompleted,
  });

  Profile.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        cityId = data['cityId'],
        cityName = data['cityName'],
        cityDistrict = data['cityDistrict'],
        fName = data['fName'] ?? "",
        lName = data['lName'] ?? "",
        address = data['address'],
        tel = data['tel'],
        mobile = data['mobile'],
        email = data['email'],
        pwd = data['pwd'],
        statulsLabel = data['statulsLabel'],
        statulsId = data['statulsId'],
        statusValidityDate = data['statusValidityDate'],
        loc = data['loc'],
        lastLoginDate = data['lastLoginDate'],
        genderId = data['genderId'],
        genderLabel = data['genderLabel'],
        occupationId = data['occupationId'],
        occupationLabel = data['occupationLabel'],
        educationId = data['educationId'],
        educationLabel = data['educationLabel'],
        maritalStatusLabel = data['maritalStatusLabel'],
        maritalStatusId = data['maritalStatusId'],
        dateOfBirth = data['dateOfBirth'],
        nbChildren = data['nbChildren'],
        transportationLabel = data['transportationLabel'],
        transportationId = data['transportationId'],
        profileCompleted = data['profileCompleted'];

  Profile.fromApi(Map<String, dynamic> data)
      : id = data['id'],
        cityId = data['city'] == null ? '' : data['city']['id'],
        cityName = data['city'] == null ? '' : data['city']['name'],
        cityDistrict = data['city'] == null ? '' : data['city']['district'],
        fName = data['fName'] ?? '',
        lName = data['lName'] ?? '',
        address = data['address'],
        tel = data['tel'],
        mobile = data['mobile'],
        email = data['email'],
        pwd = data['pwd'],
        statulsLabel = data['statulsLabel'],
        statulsId = data['statulsId'],
        statusValidityDate = data['statusValidityDate'],
        loc = data['loc'],
        lastLoginDate = data['lastLoginDate'],
        genderId = data['gender'] == null ? null : data['gender']['id'],
        genderLabel = data['gender'] == null ? null : data['gender']['label'],
        occupationId =
            data['occupation'] == null ? null : data['occupation']['id'],
        occupationLabel =
            data['occupation'] == null ? null : data['occupation']['label'],
        educationId =
            data['education'] == null ? null : data['education']['id'],
        educationLabel =
            data['education'] == null ? null : data['education']['label'],
        maritalStatusLabel = data['maritalStatus'] == null
            ? null
            : data['maritalStatus']['label'],
        maritalStatusId =
            data['maritalStatus'] == null ? null : data['maritalStatus']['id'],
        transportationLabel = data['transportation'] == null
            ? null
            : data['transportation']['label'],
        transportationId = data['transportation'] == null
            ? null
            : data['transportation']['id'],
        dateOfBirth = data['dateOfBirth'],
        nbChildren = data['nbChildren'],
        profileCompleted = data['profileCompleted'];

  Profile.combine({Profile live, Profile cache})
      : id = cache.id ?? live.id,
        cityId = cache.cityId ?? live.cityId,
        cityName = cache.cityName ?? live.cityName,
        cityDistrict = cache.cityDistrict ?? live.cityDistrict,
        fName = cache.fName ?? live.fName,
        lName = cache.lName ?? live.lName,
        address = cache.address ?? live.address,
        tel = cache.tel ?? live.tel,
        mobile = cache.mobile ?? live.mobile,
        email = cache.email ?? live.email,
        pwd = cache.pwd ?? live.pwd,
        statulsLabel = cache.statulsLabel ?? live.statulsLabel,
        statulsId = cache.statulsId ?? live.statulsId,
        statusValidityDate =
            cache.statusValidityDate ?? live.statusValidityDate,
        loc = cache.loc ?? live.loc,
        lastLoginDate = cache.lastLoginDate ?? live.lastLoginDate,
        genderId = cache.genderId ?? live.genderId,
        genderLabel = cache.genderLabel ?? live.genderLabel,
        occupationId = cache.occupationId ?? live.occupationId,
        occupationLabel = cache.occupationLabel ?? live.occupationLabel,
        educationId = cache.educationId ?? live.educationId,
        educationLabel = cache.educationLabel ?? live.educationLabel,
        maritalStatusLabel =
            cache.maritalStatusLabel ?? live.maritalStatusLabel,
        maritalStatusId = cache.maritalStatusId ?? live.maritalStatusId,
        dateOfBirth = cache.dateOfBirth ?? live.dateOfBirth,
        nbChildren = cache.nbChildren ?? live.nbChildren,
        transportationLabel =
            cache.transportationLabel ?? live.transportationLabel,
        transportationId = cache.transportationId ?? live.transportationId,
        profileCompleted = cache.profileCompleted ?? live.profileCompleted;

  bool isAdult() {
    if (dateOfBirth == null || dateOfBirth == 0) {
      return false;
    }

    final birthDate = DateTime.fromMillisecondsSinceEpoch(dateOfBirth);
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }

    return age >= 18;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'cityDistrict': cityDistrict,
      'fName': fName,
      'lName': lName,
      'address': address,
      'tel': tel,
      'mobile': mobile,
      'email': email,
      'pwd': pwd,
      'statulsLabel': statulsLabel,
      'statulsId': statulsId,
      'statusValidityDate': statusValidityDate,
      'loc': loc,
      'lastLoginDate': lastLoginDate,
      'genderId': genderId,
      'genderLabel': genderLabel,
      'occupationId': occupationId,
      'occupationLabel': occupationLabel,
      'educationId': educationId,
      'educationLabel': educationLabel,
      'maritalStatusLabel': maritalStatusLabel,
      'maritalStatusId': maritalStatusId,
      'dateOfBirth': dateOfBirth,
      'nbChildren': nbChildren,
      'transportationLabel': transportationLabel,
      'transportationId': transportationId,
    };
  }

  String toVCardData() {
    return '''BEGIN:VCARD
VERSION:3.0
N:$lName;$fName;;$genderLabel;
FN:$fName $lName
TEL;TYPE=HOME,VOICE:$mobile
LABEL;TYPE=HOME:$cityName
EMAIL;TYPE=PREF,INTERNET:$email
X-UWIN-ID:$id
END:VCARD''';
  }
}
