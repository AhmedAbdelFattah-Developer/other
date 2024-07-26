import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/auth_bloc.dart';
import 'package:uwin_flutter/src/models/gift_voucher.dart';
import 'package:uwin_flutter/src/models/user.dart';
import 'package:uwin_flutter/src/repositories/gift_voucher_repository.dart';

final _emailValid = RegExp(
  r"""(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])""",
);

class SendGiftVoucherBloc {
  SendGiftVoucherBloc(this.authBloc, this.repo);

  final _email = BehaviorSubject<String>();
  final GiftVoucherRepository repo;
  final AuthBloc authBloc;

  Stream<User> get user => authBloc.user;
  Stream<String> get email => _email.stream;

  Stream<bool> get valid => _email.stream.map((e) => true);

  Stream<GiftVoucher> getGiftVoucher(String id) => authBloc.user.switchMap(
        (u) => repo.fetchValid(u.token, u.id, id),
      );

  void changeEmail(String e) {
    if (e == null || e.isEmpty) {
      _email.sink.addError('Required');

      return;
    }

    if (!_emailValid.hasMatch(e)) {
      _email.sink.addError('Invalid email');

      return;
    }

    _email.sink.add(e);
  }

  Future<void> submit(User u, GiftVoucher giftVoucher) async {
    final tokenResult = await authBloc.firebaseUser;
    final idToken = await tokenResult.getIdToken();
    await repo.send(idToken, u.id, giftVoucher.id, _email.value);
  }

  dispose() {
    _email.close();
  }
}
