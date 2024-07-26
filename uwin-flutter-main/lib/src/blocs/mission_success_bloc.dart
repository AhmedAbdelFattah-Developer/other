import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/models/voucher.dart';
import 'package:uwin_flutter/src/repositories/mission_repository.dart';

class MissionSuccessBloc {
  final MissionRepository _missionRepository;
  final AuthBloc _authBloc;

  const MissionSuccessBloc(this._authBloc, this._missionRepository);

  Future<List<Voucher>> getVouchers(String mid) async {
    final u = await _authBloc.user.first;
    return _missionRepository.fetchMissionVouchers(mid, u.token);
  }
}
