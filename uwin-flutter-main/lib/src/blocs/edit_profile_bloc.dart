import 'package:rxdart/subjects.dart';
import 'package:uwin_flutter/src/models/transportation.dart';
import 'package:uwin_flutter/src/repositories/disclaimer_repository.dart';
import 'package:uwin_flutter/src/repositories/marital_status_repository.dart';
import 'package:uwin_flutter/src/repositories/user_repository.dart';

import '../repositories/occupation_repository.dart';
import '../repositories/city_repository.dart';
import '../repositories/gender_repository.dart';
import '../repositories/education_level_repository.dart';
import '../repositories/transportation_repository.dart';
import '../models/occupation.dart';
import '../models/gender.dart';
import '../models/city.dart';
import '../models/marital_status.dart';
import '../models/education_level.dart';
import '../models/transportation.dart';
import 'auth_bloc.dart';

class EditProfileBloc {
  final AuthBloc authBloc;
  final CityRepository cityRepo;
  final GenderRepository genderRepo;
  final OccupationRepository occupationRepo;
  final MaritalStatusRepository maritalStatusRepo;
  final TransportationRepository transportationRepo;
  final UserRepository userRepo;
  final disclaimerRepo = DisclaimerRespository();
  final _showLoader = BehaviorSubject<bool>();
  final _disclaimer = BehaviorSubject<bool>();

  EditProfileBloc(
    this.authBloc,
    this.cityRepo,
    this.genderRepo,
    this.occupationRepo,
    this.maritalStatusRepo,
    this.transportationRepo,
    this.userRepo,
  );

  Stream<bool> get showLoader => _showLoader.stream;
  Stream<bool> get disclaimer => _disclaimer.stream;

  fetchDisclaimer() async {
    try {
      _disclaimer.sink.add(await disclaimerRepo.accepted);
    } catch (err) {
      _disclaimer.sink.addError('Could not get disclaimer state');
    }
  }

  setDisclaimer(bool value) async {
    try {
      await disclaimerRepo.change(value);
      _disclaimer.sink.add(value);
    } catch (err) {
      _disclaimer.sink.addError('Could not change disclaimer state');
    }
  }

  Future<List<Gender>> get genders async {
    return genderRepo.fetchAll(await authBloc.token);
  }

  Future<List<City>> get cities async {
    return cityRepo.fetchAll(await authBloc.token);
  }

  Future<List<Occupation>> get occupations async {
    return occupationRepo.fetchAll(await authBloc.token);
  }

  Future<List<MaritalStatus>> get maritalStatusList async {
    return maritalStatusRepo.fetchAll(await authBloc.token);
  }

  Future<List<Transportation>> get transportationList async {
    return transportationRepo.fetchAll(await authBloc.token);
  }

  List<EducationLevel> get educationLevelList => EducationLevelRepository.all;

  Future submit(
    String userId,
    String firstName,
    String lasttName,
    String email,
    int dob,
    String phone,
    String cityId,
    String cityName,
    Gender gender,
    Occupation occupation,
    MaritalStatus maritalStatus,
    Transportation transportation,
    EducationLevel educationLevel,
  ) async {
    _showLoader.sink.add(true);

    try {
      final token = await authBloc.token;
      await this.userRepo.save(
            token,
            userId,
            firstName,
            lasttName,
            email,
            dob,
            phone,
            cityId,
            cityName,
            gender,
            occupation,
            maritalStatus,
            transportation,
            educationLevel,
          );

      await authBloc.updateProfile();
    } finally {
      _showLoader.sink.add(false);
    }
  }

  dispose() {
    _showLoader.close();
    _disclaimer.close();
  }
}
