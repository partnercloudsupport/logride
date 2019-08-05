import 'package:flutter/material.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/ride_type_structures.dart';
import 'package:log_ride/data/shared_prefs_data.dart';
import 'package:log_ride/data/units.dart';
import 'package:log_ride/ui/dialogs/string_list_dialog.dart';
import 'package:log_ride/widgets/dialogs/date_picker.dart';
import 'package:log_ride/widgets/dialogs/duration_picker.dart';
import 'package:log_ride/widgets/forms/form_header.dart';
import 'package:log_ride/widgets/forms/generic_list_picker_field.dart';
import 'package:log_ride/widgets/forms/proper_adaptive_switch.dart';
import 'package:log_ride/widgets/forms/ride_status_dropdown.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/forms/submission_divider.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:preferences/preferences.dart';

class SubmitAttractionPage extends StatefulWidget {
  SubmitAttractionPage({this.existingData, this.parentPark, this.pm});

  final BluehostAttraction existingData;
  final BluehostPark parentPark;
  final ParksManager pm;

  @override
  _SubmitAttractionPageState createState() => _SubmitAttractionPageState();
}

class _SubmitAttractionPageState extends State<SubmitAttractionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isNewSubmission;

  TextEditingController _openYearController;
  TextEditingController _closeYearController;

  BluehostAttraction _data;

  AttractionStatus _attractionStatus;

  Future<bool> _initModels;
  List<Model> _possibleModels;

  @override
  void initState() {
    // Establish the data we're using for editing
    if (widget.existingData == null) {
      // Creating a new attraction, create object to go alongside
      _data = BluehostAttraction();
      _isNewSubmission = true;
    } else {
      // Modifying existing attraction
      _data = widget.existingData;
      _isNewSubmission = false;
    }

    _attractionStatus = getAttractionStateFromBluehostAttraction(_data);

    _openYearController = TextEditingController(
        text: (_data.yearOpen != null && _data.yearOpen != 0)
            ? _data.yearOpen.toString()
            : "");
    _closeYearController = TextEditingController(
        text: (_data.yearClosed != null && _data.yearClosed != 0)
            ? _data.yearClosed.toString()
            : "");

    _initModels = _asyncInitModels();

    // Note - while this page reads preferences to ensure that we're in the right
    // measurement system, as it is a full page thing we don't have to listen to
    // updates. The user literally cannot press the button to change the setting
    // while in this page.

    super.initState();
  }

  Future<bool> _asyncInitModels() async {
    // Null manufacturers mean it's not set-up properly. -1 ID means it has a custom manufacturer
    // Custom Manufacturers are given a blank list of possible models. Users can enter their own model
    // names in the normal dialog box
    if (_data.manufacturerID != null && _data.manufacturerID != -1) {
      List<Model> models = await widget.pm.getModels(_data.manufacturerID);
      _possibleModels =
          (models == null) ? List<Model>() : List<Model>.from(models);
    } else {
      _possibleModels = List<Model>();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // The overall container is green so it stretches all the way up
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Container(
              // But the form's content (outside of header) is white
              color: Colors.white,

              // Forms use _formKey to be accessed later.
              child: Form(
                key: _formKey,
                autovalidate: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header
                    FormHeader(
                      text: (_isNewSubmission)
                          ? "Submit New Attraction"
                          : "Modify Existing Attraction",
                      subtext: "For ${widget.parentPark.parkName}",
                    ),

                    // This container is padding unlike the formHeader to allow the header full horizontal width
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                          children: (<Widget>[]
                                // Sections are split into various functions for increased readability
                                ..addAll(_buildCoreInformation(context))
                                ..addAll(_buildOperatingHistory(context))
                                ..addAll(_buildFactsAndStats(context)))
                              .map((entry) {
                        return Padding(
                          child: entry,
                          padding: EdgeInsets.only(top: 4.0),
                        );
                      }).toList()),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: <Widget>[
        InterfaceButton(
          text: "Cancel",
          onPressed: () => Navigator.of(context).pop(),
          color: UI_BUTTON_BACKGROUND,
          textColor: Colors.black,
        ),
        InterfaceButton(
          text: "Submit",
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              Navigator.of(context).pop(_data);
            }
          },
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ],
    );
  }

  List<Widget> _buildCoreInformation(BuildContext context) {
    return [
      TextFormField(
        decoration: submissionDecoration(
            labelText: "Name *", hintText: "Attraction Name"),
        initialValue: _data.attractionName,
        textCapitalization: TextCapitalization.words,
        validator: (value) {
          if (value.isEmpty) {
            return "Please enter the name of the attraction";
          }

          return null;
        },
        onSaved: (value) {
          _data.attractionName = value;
        },
      ),
      RideTypePickerFormField(
        widget.pm.attractionTypes,
        initialValue: _data.rideType,
        validator: (RideType v) {
          if (v == null || v.id == 0) return "Please select a valid ride type";
          return null;
        },
        onSaved: (RideType v) {
          _data.rideType = v;
          _data.rideTypeID = v.id;
          _data.typeLabel = v.label;
        },
      ),
      /*
      FormField(
        // Ok, attractions have it stored as
        initialValue: _data.rideType,
        onSaved: (v) {
          _data.rideType = v;
        },
        builder: (FormFieldState<int> state) {
          return InputDecorator(
            decoration: submissionDecoration(
              hintText: "Attraction Type",
              labelText: "Type *",
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: state.value,
                onChanged: (value) {
                  state.didChange(value);
                },
                items: dropDownTypes,
              ),
            ),
          );
        },
      ),*/
      StringListField(
        onSaved: (d) {
          _data.formerNames = d;
        },
        initialValue: _data.formerNames,
        label: "Former Names",
        headerText: "Former Names",
        hintText: "ex: Former Name [2001-2012]",
        emptyText: "Tap the button below to add a former name to the list.",
        unit: "Name",
      ),
      SubmissionDivider(),
    ];
  }

  List<Widget> _buildOperatingHistory(BuildContext context) {
    return <Widget>[
      RideStatusDropdown(
        onChanged: (status) {
          // We update the attraction status if it's both different
          // and we're mounted. This is used to select which
          // text boxes are available.
          if (status != _attractionStatus) {
            if (mounted) {
              setState(() {
                _attractionStatus = status;
              });
            }
          }
        },
        onSaved: (status) {
          _data = applyStatusToAttraction(status, _data);
        },
        initialValue: _data,
      ),
      AdaptiveSwitchFormField(
        initialValue: _data.seasonal,
        label: "Seasonal",
        onSaved: (val) => _data.seasonal = val,
      ),
      TextFormField(
        controller: _openYearController,
        decoration: submissionDecoration(
            labelText: (_attractionStatus == AttractionStatus.UPCOMING)
                ? "Year Opening"
                : "Year Opened",
            hintText: "Opening Year"),
        keyboardType: TextInputType.numberWithOptions(),
        validator: (value) {
          if (value == "") return null;

          if ((num.tryParse(value) ?? 0) <= 0) {
            return "Please enter a valid year.";
          }

          return null;
        },
        onSaved: (value) {
          _data.yearOpen = num.tryParse(value);
        },
      ),
      DatePickerFormField(
        onSaved: (d) {
          _data.openingDay = d;
        },
        validator: (v) {
          if (_attractionStatus == AttractionStatus.UPCOMING && v == null) {
            return "Enter an opening date";
          }

          return null;
        },
        initialValue: _data.openingDay,
        text: (_attractionStatus == AttractionStatus.UPCOMING)
            ? "Date Opening"
            : "Date Opened",
        onUpdate: (d) {
          if (d == null) return;

          if (_openYearController.text != d.year.toString()) {
            setState(() {
              _openYearController.text = d.year.toString();
            });
          }
        },
      ),
      TextFormField(
        controller: _closeYearController,
        decoration: submissionDecoration(
          hintText: "Closing Year",
          labelText: "Year Closed",
        ),
        enabled: (_attractionStatus == AttractionStatus.DEFUNCT),
        keyboardType: TextInputType.numberWithOptions(),
        validator: (value) {
          if (value == "") return null;

          if ((num.tryParse(value) ?? 0) <= 0) {
            return "Please enter a valid year.";
          }

          return null;
        },
        onSaved: (value) {
          _data.yearClosed = num.tryParse(value);
        },
      ),
      DatePickerFormField(
        onSaved: (d) {
          _data.closingDay = d;
        },
        enabled: (_attractionStatus == AttractionStatus.DEFUNCT),
        initialValue: _data.closingDay,
        text: "Date Closed",
        onUpdate: (d) {
          if (d == null) return;

          if (d.year.toString() != _closeYearController.text) {
            _closeYearController.text = d.year.toString();
          }
        },
      ),
      StringListField(
        onSaved: (d) {
          _data.inactivePeriods = d;
        },
        initialValue: _data.inactivePeriods,
        label: "Years Inactive",
        headerText: "Years Inactive",
        hintText: "ex: 2008-2012",
        emptyText:
            "Tap the button below to add an inactive period to the list.",
      ),
      SubmissionDivider(),
    ];
  }

  List<Widget> _buildFactsAndStats(BuildContext context) {
    Manufacturer initialManufacturer =
        (_data.manufacturerID != null && _data.manufacturerID != -1)
            ? getManufacturerById(widget.pm.manufacturers, _data.manufacturerID)
            : null;
    if (initialManufacturer == null &&
        _data.manufacturer != "" &&
        _data.manufacturer != null) {
      // Some attractions have manufacturer labels but no manufacturer ID - in this case, we create a "fake" manufacturer
      initialManufacturer = Manufacturer(id: null, name: _data.manufacturer);
    }

    Model initialModel = (_data.modelID != null && _possibleModels != null)
        ? getModelByID(_possibleModels, _data.modelID)
        : null;

    if (initialModel == null && _data.model != "" && _data.model != null) {
      // Some attractions have models that aren't registered in our database - handle these as custom manufacturers
      initialModel = Model(id: null, name: _data.model);
    }

    bool usingMetric =
        PrefService.getBool(preferencesKeyMap[PREFERENCE_KEYS.USE_METRIC]);

    num initialHeight = _data.height;
    if (initialHeight != null && initialHeight != 0.0 && usingMetric)
      initialHeight =
          roundUnit(convertUnit(initialHeight, Unit.foot, Unit.meter));

    num initialSpeed = _data.maxSpeed;
    if (initialSpeed != null && initialSpeed != 0.0 && usingMetric)
      initialSpeed = roundUnit(convertUnit(initialSpeed, Unit.mph, Unit.kph));

    num initialLength = _data.length;
    if (initialLength != null && initialLength != 0.0 && usingMetric)
      initialLength =
          roundUnit(convertUnit(initialLength, Unit.foot, Unit.meter));

    return <Widget>[
      ManufacturerPickerFormField(
        widget.pm.manufacturers,
        initialValue: initialManufacturer,
        onSaved: (d) {
          if (d == null) {
            _data.manufacturer = "";
            _data.manufacturerID = 0;
          } else {
            _data.manufacturer = d.name;
            _data.manufacturerID = d.id;
          }
        },
        onUpdate: (m) async {
          if (m == null) {
            setState(() {
              _possibleModels = List<Model>();
            });
            return;
          }

          if (m.id != _data.manufacturerID) {
            List<Model> models = await widget.pm.getModels(m.id);
            setState(() {
              _possibleModels =
                  (models == null) ? List<Model>() : List<Model>.from(models);
            });
          }
        },
      ),
      StringListField(
        onSaved: (d) {
          _data.additionalContributors = d;
        },
        initialValue: _data.additionalContributors,
        label: "Contributors",
        headerText: "Contributors",
        hintText: "ex: ITEC Entertainment, Nassal",
        emptyText:
            "Tap the button below to add a Contributing Organization to the list.",
      ),
      FutureBuilder(
          future: _initModels,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ModelPickerFormField(
                _possibleModels,
                initialValue: initialModel,
                onSaved: (d) {
                  if (d == null) {
                    _data.modelID = 0;
                    _data.model = "";
                  } else {
                    _data.modelID = d.id;
                    _data.model = d.name;
                  }
                },
              );
            } else {
              return TextFormField(
                initialValue: _data.model,
                decoration: submissionDecoration(
                  labelText: "Model",
                ),
              );
            }
          }),
      TextFormField(
        initialValue: (initialHeight != null && initialHeight != 0.0)
            ? initialHeight.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Height",
          labelText: "Height",
          suffixText: (usingMetric) ? "m " : "ft ",
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == "") return null;

          num parsed = num.tryParse(value);
          if (parsed == null) {
            return "Please enter a valid height";
          } else if (parsed <= 0) {
            return "Please enter a positive height";
          }

          return null;
        },
        onSaved: (value) {
          num parsed = num.tryParse(value);
          if (parsed == null) {
            _data.height = 0;
            return;
          }
          _data.height = (usingMetric)
              ? roundUnit(convertUnit(parsed, Unit.meter, Unit.foot))
              : parsed;
        },
      ),
      TextFormField(
        initialValue: (initialSpeed != null && initialSpeed != 0.0)
            ? initialSpeed.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Speed",
          labelText: "Max Speed",
          suffixText: (usingMetric) ? "kph " : "mph ",
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == "") return null;

          num parsed = num.tryParse(value);
          if (parsed == null) {
            return "Please enter a valid speed";
          } else if (parsed <= 0) {
            return "Please enter a positive speed";
          }

          return null;
        },
        onSaved: (value) {
          num parsed = num.tryParse(value);
          if (parsed == null) {
            _data.maxSpeed = 0;
            return;
          }
          _data.maxSpeed = (usingMetric)
              ? roundUnit(convertUnit(parsed, Unit.kph, Unit.mph))
              : parsed;
        },
      ),
      TextFormField(
        initialValue: (initialLength != null && initialLength != 0.0)
            ? initialLength.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Length",
          labelText: "Length",
          suffixText: (usingMetric) ? "m " : "ft ",
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == "") return null;

          num parsed = num.tryParse(value);
          if (parsed == null) {
            return "Please enter a valid length";
          } else if (parsed <= 0) {
            return "Please enter a positive length";
          }

          return null;
        },
        onSaved: (value) {
          num parsed = num.tryParse(value);
          if (parsed == null) {
            _data.length = 0;
            return;
          }
          _data.length = (usingMetric)
              ? roundUnit(convertUnit(parsed, Unit.meter, Unit.foot))
              : parsed;
        },
      ),
      DurationPickerFormField(
        initialValue: Duration(seconds: _data.attractionDuration ?? 0),
        onSaved: (d) => _data.attractionDuration = d.inSeconds,
      ),
      TextFormField(
        initialValue: (_data.inversions != null && _data.inversions != 0.0)
            ? _data.inversions.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Inversions",
          labelText: "Inversions",
          suffixText: "  ",
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: false),
        validator: (value) {
          if (value == "") return null;

          num parsed = num.tryParse(value);
          if (parsed == null) {
            return "Please enter a valid number of inversions";
          } else if (parsed <= 0) {
            return "Please enter a positive number of inversions";
          }

          return null;
        },
        onSaved: (value) {
          _data.inversions = num.tryParse(value);
        },
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: AdaptiveSwitchFormField(
          label: "Scorecard",
          initialValue: _data.scoreCard,
          onSaved: (val) => _data.scoreCard = val,
        ),
      ),
      TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue: _data.notes,
        textCapitalization: TextCapitalization.sentences,
        onSaved: (n) {
          _data.notes = n;
        },
        decoration: submissionDecoration(labelText: "Notes"),
      ),
    ];
  }
}
