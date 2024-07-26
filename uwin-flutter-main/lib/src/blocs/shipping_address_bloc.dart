import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/blocs/providers/shop_bloc_provider.dart';
import 'package:uwin_flutter/src/models/profile.dart';
import 'package:uwin_flutter/src/models/sales_order.dart';
import 'package:uwin_flutter/src/models/shipping_details.dart';
import 'package:uwin_flutter/src/models/shop.dart';
import 'package:uwin_flutter/src/repositories/sales_order_repository.dart';
import 'package:uwin_flutter/src/repositories/shop_repository.dart';

bool _isNotEmpty(String val) {
  return val != null && val.isNotEmpty;
}

final _emailValid = RegExp(
  r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""",
);

class ShippingAddressBloc {
  ShippingAddressBloc({
    @required this.authBloc,
    @required this.shopRepo,
    @required this.soRepo,
  });

  final SalesOrderRepository soRepo;
  final _firstName = BehaviorSubject<String>();
  final _lastName = BehaviorSubject<String>();
  final _email = BehaviorSubject<String>();
  final _phone = BehaviorSubject<String>();
  final _street = BehaviorSubject<String>();
  final _city = BehaviorSubject<String>();
  final _postCode = BehaviorSubject<String>();
  final _showSpinner = BehaviorSubject<bool>();

  void Function(String) get changeFirstName => _firstName.sink.add;
  void Function(String) get changeLastName => _lastName.sink.add;
  void Function(String) get changeEmail => _email.sink.add;
  void Function(String) get changePhone => _phone.sink.add;
  void Function(String) get changeStreet => _street.sink.add;
  void Function(String) get changeCity => _city.sink.add;
  void Function(String) get changePostCode => _postCode.sink.add;

  final ShopRepository shopRepo;
  final AuthBloc authBloc;

  void init() {
    _showSpinner.add(false);
  }

  Stream<bool> get isValid =>
      Rx.combineLatest6<String, String, String, String, String, String, bool>(
        _firstName.stream,
        _lastName.stream,
        _email.stream,
        _phone.stream,
        _street.stream,
        _city.stream,
        (
          firstNameVal,
          lastNameVal,
          emailVal,
          phoneVal,
          streetVal,
          cityVal,
        ) {
          if (!_isNotEmpty(firstNameVal)) {
            return false;
          }

          if (!_isNotEmpty(lastNameVal)) {
            return false;
          }

          if (!_isNotEmpty(emailVal)) {
            return false;
          }

          if (!_isNotEmpty(phoneVal)) {
            return false;
          }

          if (!_isNotEmpty(streetVal)) {
            return false;
          }

          if (!_isNotEmpty(cityVal)) {
            return false;
          }

          return true;
        },
      );

  Stream<Shop> getShop(String shopId) => authBloc.user
      .switchMap((u) => shopRepo.fetch(u.token, shopId).asStream());

  Stream<Profile> get profile => authBloc.profile;

  Stream<ButtonState> get buttonState =>
      Rx.combineLatest2<bool, bool, ButtonState>(
        _showSpinner.stream,
        isValid,
        (showSpinnerVal, isValidVal) {
          if (showSpinnerVal) {
            return ButtonStates.spinning;
          }

          if (isValidVal) {
            return ButtonStates.enabled;
          }

          return ButtonStates.disabled;
        },
      );

  Future<void> placeOrder(SalesOrder so) async {
    _showSpinner.sink.add(true);
    so.shippingDetails = ShippingDetails(
      firstName: _firstName.value,
      lastName: _lastName.value,
      email: _email.value,
      phone: _phone.value,
      street: _street.value,
      city: _city.value,
      postCode: _postCode.value,
    );

    try {
      await soRepo.placeOrder(so);
      await soRepo.saveLastShippingDetails(so.userId, so.shippingDetails);
    } finally {
      _showSpinner.sink.add(false);
    }
  }

  Stream<ShippingDetails> get lastShippingDetails => authBloc.user.switchMap(
        (u) => soRepo.getLastShippingDetails(u.id, u.token).asStream(),
      );

  bool _validateIsNotEmpty(String val) {
    return val != null && val.isNotEmpty;
  }

  bool _validateEmail(String val) {
    return _emailValid.hasMatch(val);
  }

  Stream<bool> get firstNameValid => _firstName.map(
        (v) => _validateIsNotEmpty(v),
      );
  Stream<bool> get lastNameValid => _lastName.map(
        (v) => _validateIsNotEmpty(v),
      );
  Stream<bool> get emailValid => _email.map(
        (v) => _validateIsNotEmpty(v) && _validateEmail(v),
      );
  Stream<bool> get phoneValid => _phone.map((v) => _validateIsNotEmpty(v));
  Stream<bool> get streetValid => _street.map((v) => _validateIsNotEmpty(v));
  Stream<bool> get cityValid => _city.map((v) => _validateIsNotEmpty(v));

  dispose() {
    _firstName.close();
    _lastName.close();
    _email.close();
    _phone.close();
    _street.close();
    _city.close();
    _postCode.close();
    _showSpinner.close();
  }
}
