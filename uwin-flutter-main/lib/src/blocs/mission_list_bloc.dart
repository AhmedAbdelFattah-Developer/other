import 'package:rxdart/rxdart.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/models/mission.dart';
import 'package:uwin_flutter/src/repositories/mission_repository.dart';

class MissionListBloc {
  final AuthBloc authBloc;
  final MissionRepository repo;
  final _missionList = PublishSubject<List<Mission>>();

  MissionListBloc(this.authBloc, this.repo);

  Stream<List<Mission>> get list => _missionList.stream;

  void fetchList() async {
    authBloc.user.switchMap((u) => repo.findAll(u.id, u.token)).listen((event) {
      _missionList.sink.add(event);
    }, onError: (e) {
      _missionList.sink.addError(e);
    });
  }

  Future<String> getUrl(Mission mission) async {
    final u = await this.authBloc.user.first;
    return '${mission.url}?ProjectReference=${mission.id}&uWinUser=${u.id}';
  }

  Future<List<String>> fetchMissionVouchers(String missionId) async {
    final u = await this.authBloc.user.first;
    final list = await repo.fetchMissionVouchers(missionId, u.token);
    return list.map((v) => '• ${v.shopName} (Rs${v.amount})').toList();
  }

  void dispose() {
    _missionList.close();
  }
}
