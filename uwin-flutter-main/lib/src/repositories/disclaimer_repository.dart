import 'package:shared_preferences/shared_preferences.dart';

const _acceptedKey = 'disclaimer_accepted';

class DisclaimerRespository {
  Future<bool> get accepted async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_acceptedKey) != false;
    } catch (err) {
      print(
          '[DisclaimerRespository.accepted] Could not access shared preferences');
      print(err);

      return false;
    }
  }

  change(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(_acceptedKey, value);
    } catch (err) {
      print(
          '[DisclaimerRespository.accepted] Could not access shared preferences');
      print(err);
    }
  }
}
