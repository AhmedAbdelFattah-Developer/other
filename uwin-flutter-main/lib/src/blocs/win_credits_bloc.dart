import 'package:uwin_flutter/src/models/win_credits_content.dart';
import 'package:uwin_flutter/src/repositories/win_credits_repository.dart';

class WinCreditsBloc {
  WinCreditsBloc(this.repo);

  final WinCreditsRepository repo;

  Stream<WinCreditsContent> get winCredits => repo.winCredits;

  dispose() {}
}
