import 'package:flutter/material.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';

import '../../repositories/marital_status_repository.dart';
import '../../repositories/occupation_repository.dart';
import '../../repositories/city_repository.dart';
import '../../repositories/gender_repository.dart';
import '../../repositories/transportation_repository.dart';
import '../auth_bloc.dart';
import '../edit_profile_bloc.dart';
export '../edit_profile_bloc.dart';

class EditProfileBlocProvider extends InheritedWidget {
  final EditProfileBloc bloc;

  EditProfileBlocProvider({
    Key key,
    Widget child,
    @required AuthBloc authBloc,
    @required CityRepository cityRepo,
    @required GenderRepository genderRepo,
    @required OccupationRepository occupationRepo,
    @required MaritalStatusRepository maritalStatusRepo,
    @required TransportationRepository transportationRepo,
    @required UserRepository userRepo,
  })  : bloc = EditProfileBloc(
          authBloc,
          cityRepo,
          genderRepo,
          occupationRepo,
          maritalStatusRepo,
          transportationRepo,
          userRepo,
        ),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static EditProfileBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EditProfileBlocProvider>().bloc;
  }
}
