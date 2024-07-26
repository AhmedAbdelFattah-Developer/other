class ShippingDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String postCode;

  ShippingDetails({
    this.email,
    this.city,
    this.firstName,
    this.lastName,
    this.phone,
    this.postCode,
    this.street,
  });

  ShippingDetails.fromMap(Map<String, dynamic> data)
      : email = data['email'],
        city = data['city'],
        firstName = data['firstName'],
        lastName = data['lastName'],
        phone = data['phone'],
        postCode = data['postCode'],
        street = data['street'];

  Map<String, dynamic> get toMap => <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'street': street,
        'city': city,
        'postCode': postCode,
      };
}
