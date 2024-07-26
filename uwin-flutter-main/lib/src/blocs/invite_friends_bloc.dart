import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';

class InviteFriendsBloc {
  final UserRepository _userRepository;
  final AuthBloc _authBloc;

  InviteFriendsBloc(this._authBloc, this._userRepository);

  Stream<String> get referalCode => _authBloc.user
      .switchMap((user) => _userRepository.getReferalCode(user.id, user.token));

  Stream<int> get invitedCount => _authBloc.user.switchMap(
      (user) => _userRepository.getInvitedCount(user.id, user.token));

  inviteFriends() {}
}
