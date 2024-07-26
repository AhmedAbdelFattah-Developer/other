import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../blocs/providers/auth_block_provider.dart';
import '../blocs/providers/edit_profile_bloc_provider.dart';
import '../models/marital_status.dart';
import '../models/profile.dart';
import '../models/gender.dart';
import '../models/occupation.dart';
import '../models/city.dart';
import '../models/transportation.dart';
import '../models/education_level.dart';

const _formControlDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(
    Radius.circular(3.0),
  ),
);

class EditProfileScreen extends StatelessWidget {
  static const routeName = '/edit-profile';

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBlocProvider.of(context);

    return CupertinoPageScaffold(
      backgroundColor: Color(0xFFEFEFEF),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('Edit Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(8.0),
          child: Text('logout', style: TextStyle(color: Colors.black)),
          color: Colors.transparent,
          onPressed: () {
            authBloc.logout();
          },
        ),
      ),
      child: StreamBuilder<Profile>(
          stream: authBloc.profile,
          builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return _EditProfileForm(snapshot.data);
          }),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final Profile profile;
  final bool isIOs;

  _EditProfileForm(this.profile) : isIOs = Platform.isIOS;

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneNameCtrl = TextEditingController();
  bool showLoader = false;
  int dob;
  String cityId;
  String cityName;
  Gender gender;
  Occupation occupation;
  MaritalStatus maritalStatus;
  EducationLevel educationLevel;
  Transportation transportation;

  @override
  void initState() {
    firstNameCtrl.text = widget.profile.fName;
    lastNameCtrl.text = widget.profile.lName;
    phoneNameCtrl.text = widget.profile.mobile;
    dob = widget.profile.dateOfBirth ?? 0;
    cityId = widget.profile.cityId;
    cityName = widget.profile.cityName;
    gender = Gender(
      id: widget.profile.genderId,
      label: widget.profile.genderLabel,
    );
    occupation = Occupation(
      id: widget.profile.occupationId,
      label: widget.profile.occupationLabel,
    );
    maritalStatus = MaritalStatus(
      id: widget.profile.maritalStatusId,
      label: widget.profile.maritalStatusLabel,
    );
    educationLevel = EducationLevel(
      id: widget.profile.educationId,
      label: widget.profile.educationLabel,
    );
    transportation = Transportation(
      id: widget.profile.transportationId,
      label: widget.profile.transportationLabel,
    );

    super.initState();
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(
        top: 32.0,
        bottom: 6.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 13.0,
        ),
      ),
    );
  }

  Widget _buildTextField({TextEditingController controller}) {
    return Container(
      height: 44.0,
      child: CupertinoTextField(
        controller: controller,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        style: TextStyle(
          color: Color(0xff000000),
          fontSize: 17.0,
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final bloc = EditProfileBlocProvider.of(context);

    return Material(
      child: Container(
        margin: EdgeInsets.all(20.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTitle('TELL US ABOUT YOU'),
                _buildLabel('First name'),
                _buildTextField(controller: firstNameCtrl),
                _buildLabel('Last name'),
                _buildTextField(controller: lastNameCtrl),
                _buildLabel('Phone'),
                _buildTextField(controller: phoneNameCtrl),
                _buildLabel('Title'),
                _buildGenderFormControl(context, bloc),
                _buildLabel('What is your birth date ?'),
                _buildDobFormControl(context, bloc),
                _buildLabel('Where do you live?'),
                _buildCityFormControl(context, bloc),
                _buildLabel('Your marital status'),
                _buildMaritalStatusFormControl(context, bloc),
                _buildLabel('What is your occupation?'),
                _buildOccupationFormControl(context, bloc),
                _buildLabel('Main mode of transport?'),
                _buildTransportFormControl(context, bloc),
                _buildLabel('What is your level of education?'),
                _buildEducationLevelFormControl(context, bloc),
                SizedBox(height: 30.0),
                _buildDisclaimer(context),
                SizedBox(height: 30.0),
                StreamBuilder<bool>(
                    stream: bloc.showLoader,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data) {
                        return CupertinoButton(
                          child: Center(child: CupertinoActivityIndicator()),
                          onPressed: null,
                        );
                      }

                      return Container(
                        width: double.infinity,
                        child: CupertinoButton(
                          child: Text('Submit'),
                          color: Color(0xFFE58213),
                          onPressed: () async {
                            try {
                              showLoader = true;
                              await bloc.submit(
                                widget.profile.id,
                                firstNameCtrl.text,
                                lastNameCtrl.text,
                                widget.profile.email,
                                dob,
                                phoneNameCtrl.text,
                                cityId,
                                cityName,
                                gender,
                                occupation,
                                maritalStatus,
                                transportation,
                                educationLevel,
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              print('[edit_profile_screen] $e');
                            } finally {
                              showLoader = false;
                            }
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final bloc = EditProfileBlocProvider.of(context);

    return Material(
      child: Container(
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1.0, color: Colors.black12),
        ),
        child: StreamBuilder<bool>(
            stream: bloc.disclaimer,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error);
              }

              return ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed('/disclaimer');
                },
                trailing: CupertinoSwitch(
                  value: snapshot.data != false,
                  onChanged: bloc.setDisclaimer,
                ),
                title: Text(
                  'Disclaimer',
                  style:
                      TextStyle(color: CupertinoTheme.of(context).primaryColor),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildMaritalStatusFormControl(
    BuildContext context,
    EditProfileBloc bloc,
  ) {
    return FutureBuilder<List<MaritalStatus>>(
      future: bloc.maritalStatusList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'An unexpected error has occured while loading marital status');
        }

        if (!snapshot.hasData) {
          return Container(
            height: 44.0,
          );
        }

        final data = [
          if (widget.isIOs) MaritalStatus(id: -1, label: 'Unset'),
          ...snapshot.data,
        ];

        return Container(
          height: 44.0,
          child: CupertinoSegmentedControl<int>(
            groupValue: maritalStatus.id,
            padding: EdgeInsets.all(0),
            children: Map.fromIterable(
              data,
              key: (ms) => ms.id,
              value: (ms) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 3.0,
                ),
                child: Text(
                  _getMaritalStatusLabel(ms.label),
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
            ),
            onValueChanged: (int value) {
              setState(() {
                maritalStatus = data.firstWhere((ms) => ms.id == value);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildGenderFormControl(
    BuildContext context,
    EditProfileBloc bloc,
  ) {
    return FutureBuilder<List<Gender>>(
      future: bloc.genders,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('[edit_profile_screen] gender list error: ${snapshot.error}');
          return Text('An unexpected error has occured while loading genders');
        }

        if (!snapshot.hasData) {
          return Container(
            height: 44.0,
          );
        }

        final dataWithNone = [
          if (widget.isIOs) Gender(id: -1, label: 'Unset', title: 'Unset'),
          ...snapshot.data,
        ];

        final map = Map<int, Widget>.fromIterable(
          dataWithNone,
          key: (g) => g.id,
          value: (g) => Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 20.0,
            ),
            child: Text(g.title),
          ),
        );

        return Container(
          height: 44.0,
          child: CupertinoSegmentedControl<int>(
            groupValue: gender.id,
            padding: EdgeInsets.all(0),
            children: map,
            onValueChanged: (int value) {
              setState(() {
                gender = dataWithNone.firstWhere((g) => value == g.id);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDobFormControl(
    BuildContext context,
    EditProfileBloc bloc,
  ) {
    return Container(
      decoration: _formControlDecoration,
      child: ListTile(
        onTap: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (widget.isIOs)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  dob = 0;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('unset'),
                            ),
                          SizedBox(width: 16.0),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('done'),
                          ),
                        ],
                      ),
                    ),
                    CupertinoTheme(
                      data: CupertinoTheme.of(context).copyWith(
                          textTheme: CupertinoTheme.of(context)
                              .textTheme
                              .copyWith(
                                  dateTimePickerTextStyle: TextStyle(
                                      fontSize: 16.0, color: Colors.black))),
                      child: Container(
                        color: Colors.white,
                        height: 200.0,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime:
                              DateTime.fromMillisecondsSinceEpoch(dob),
                          onDateTimeChanged: (DateTime date) {
                            setState(() {
                              dob = date.millisecondsSinceEpoch;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        trailing: Icon(CupertinoIcons.pencil),
        title: Text(
          (dob == null || dob == 0) && widget.isIOs
              ? 'Not set'
              : DateFormat('d MMM y')
                  .format(new DateTime.fromMillisecondsSinceEpoch(dob)),
        ),
      ),
    );
  }

  Widget _buildCityFormControl(BuildContext context, EditProfileBloc bloc) {
    return FutureBuilder<List<City>>(
      future: bloc.cities,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('An unexpected error has occured while loading cities');
        }

        if (!snapshot.hasData) {
          return Container(
            height: 100.0,
          );
        }

        return Container(
          decoration: _formControlDecoration,
          child: ListTile(
            title: Text(cityName),
            trailing: Icon(CupertinoIcons.pencil),
            onTap: () {
              final initialItem = snapshot.data
                  .map<String>((c) => c.id)
                  .toList()
                  .indexOf(cityId);
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              if (widget.isIOs)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      cityId = '-1';
                                      cityName = 'Not set';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('unset'),
                                ),
                              SizedBox(width: 16.0),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('done'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200.0,
                          child: CupertinoTheme(
                            data: CupertinoTheme.of(context).copyWith(
                              textTheme:
                                  CupertinoTheme.of(context).textTheme.copyWith(
                                        pickerTextStyle:
                                            TextStyle(color: Colors.black),
                                      ),
                            ),
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem:
                                    initialItem == -1 ? 0 : initialItem,
                              ),
                              backgroundColor: Colors.white,
                              itemExtent: 40.0,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  cityId = snapshot.data[index].id;
                                  cityName = snapshot.data[index].name;
                                });
                              },
                              children: snapshot.data.map<Widget>((city) {
                                return Text(
                                  city.name,
                                  style: TextStyle(fontSize: 22),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOccupationFormControl(
      BuildContext context, EditProfileBloc bloc) {
    return FutureBuilder<List<Occupation>>(
      future: bloc.occupations,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'An unexpected error has occured while loading occupations');
        }

        if (!snapshot.hasData) {
          return Container(
            height: 100.0,
          );
        }

        return Container(
          decoration: _formControlDecoration,
          child: ListTile(
            title: Text(occupation.label ?? ''),
            trailing: Icon(CupertinoIcons.pencil),
            onTap: () {
              final initialItem = snapshot.data
                  .map((occ) => occ.id)
                  .toList()
                  .indexOf(occupation.id);

              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              if (widget.isIOs)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(
                                      () {
                                        occupation = Occupation(
                                          label: 'Not set',
                                          id: -1,
                                        );
                                      },
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('unset'),
                                ),
                              SizedBox(width: 16.0),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('done'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200.0,
                          child: CupertinoTheme(
                            data: CupertinoTheme.of(context).copyWith(
                              textTheme:
                                  CupertinoTheme.of(context).textTheme.copyWith(
                                        pickerTextStyle:
                                            TextStyle(color: Colors.black),
                                      ),
                            ),
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                  initialItem: initialItem ?? 0),
                              backgroundColor: Colors.white,
                              itemExtent: 28.0,
                              onSelectedItemChanged: (int value) {
                                setState(() {
                                  occupation = snapshot.data
                                      .firstWhere((occ) => occ.id == value);
                                });
                              },
                              children: snapshot.data.map<Widget>((occ) {
                                return Text(
                                  occ.label,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransportFormControl(
    BuildContext context,
    EditProfileBloc bloc,
  ) {
    return FutureBuilder<List<Transportation>>(
      future: bloc.transportationList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'An unexpected error has occured while loading transportations');
        }

        if (!snapshot.hasData) {
          return Container(
            height: 44.0,
          );
        }

        final data = [
          if (widget.isIOs) Transportation(id: -1, label: 'Unset'),
          ...snapshot.data,
        ];

        return Container(
          height: 44.0,
          child: CupertinoSegmentedControl<int>(
            groupValue: transportation.id,
            padding: EdgeInsets.all(0),
            children: Map.fromIterable(
              data,
              key: (ms) => ms.id,
              value: (ms) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 3.0,
                ),
                child: Text(
                  _getTransport(ms.label),
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
            ),
            onValueChanged: (int value) {
              setState(() {
                transportation = data.firstWhere((trans) => trans.id == value);
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildEducationLevelFormControl(
    BuildContext context,
    EditProfileBloc bloc,
  ) {
    final data = [
      if (widget.isIOs) EducationLevel(id: -1, label: 'Unset'),
      ...bloc.educationLevelList,
    ];

    return Container(
      height: 44.0,
      child: CupertinoSegmentedControl<String>(
        groupValue: educationLevel.label,
        padding: EdgeInsets.all(0),
        children: Map.fromIterable(
          data,
          key: (el) => el.label,
          value: (el) => Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 5.0,
            ),
            child: Text(el.label),
          ),
        ),
        onValueChanged: (String value) {
          setState(() {
            educationLevel = data.firstWhere((el) => el.label == value);
          });
        },
      ),
    );
  }

  String _getMaritalStatusLabel(String label) {
    if (label == 'Married') {
      return 'Married / Couple';
    }

    return label;
  }

  String _getTransport(String label) {
    if (label == 'Bus') {
      return 'Bus / Metro';
    }

    return label;
  }
}
