import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';

class DeleteAccountBloc {
  final UserRepository _userRepository;
  final AuthBloc _authBloc;

  DeleteAccountBloc(this._userRepository, this._authBloc);

  Future<void> deleteAccount() async {
    final u = await _authBloc.user.first;
    debugPrint('[delete_account_bloc] delete account for user ${u.id}');

    await _userRepository.deleteAccount(u.id, u.token);
    debugPrint('[delete_account_bloc] delete account success');

    final fu = await _authBloc.firebaseUser;
    await fu.delete();
  }
}
