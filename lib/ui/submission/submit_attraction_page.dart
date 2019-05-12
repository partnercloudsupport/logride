import 'package:flutter/material.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/ui/dialogs/string_list_dialog.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/forms/form_header.dart';
import 'package:log_ride/widgets/forms/proper_adaptive_switch.dart';
import 'package:log_ride/widgets/forms/submission_divider.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/forms/ride_status_dropdown.dart';
import 'package:log_ride/widgets/dialogs/duration_picker.dart';
import 'package:log_ride/widgets/dialogs/date_picker.dart';

class SubmitAttractionPage extends StatefulWidget {
  SubmitAttractionPage(
      {this.existingData, this.parentPark, this.attractionTypes});

  final BluehostAttraction existingData;
  final BluehostPark parentPark;
  final Map<int, String> attractionTypes;

  @override
  _SubmitAttractionPageState createState() => _SubmitAttractionPageState();
}

class _SubmitAttractionPageState extends State<SubmitAttractionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isNewSubmission;

  List<DropdownMenuItem<int>> dropDownTypes;

  BluehostAttraction _data;

  AttractionStatus _attractionStatus;

  // Node definitions - used for seamless progression to the next entry
  final FocusNode _nodeName = FocusNode();

  final FocusNode _nodeFormer = FocusNode();
  final FocusNode _nodeOpenYear = FocusNode();
  final FocusNode _nodeOpenDate = FocusNode();
  final FocusNode _nodeCloseYear = FocusNode();
  final FocusNode _nodeCloseDate = FocusNode();

  final FocusNode _nodeManufacturer = FocusNode();
  final FocusNode _nodeContrib = FocusNode();
  final FocusNode _nodeModel = FocusNode();
  final FocusNode _nodeHeight = FocusNode();
  final FocusNode _nodeMaxSpeed = FocusNode();
  final FocusNode _nodeLength = FocusNode();
  final FocusNode _nodeInversions = FocusNode();

  final FocusNode _nodeNotes = FocusNode();

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

    dropDownTypes = List<DropdownMenuItem<int>>();

    // Build our attraction types list
    widget.attractionTypes.forEach((val, label) {
      dropDownTypes.add(DropdownMenuItem<int>(child: Text(label), value: val));
    });

    super.initState();
  }

  @override
  void dispose() {
    // Disposal of FocusNodes are required
    _nodeName.dispose();
    _nodeFormer.dispose();
    _nodeOpenYear.dispose();
    _nodeOpenDate.dispose();
    _nodeCloseYear.dispose();
    _nodeCloseDate.dispose();
    _nodeManufacturer.dispose();
    _nodeContrib.dispose();
    _nodeModel.dispose();
    _nodeHeight.dispose();
    _nodeMaxSpeed.dispose();
    _nodeLength.dispose();
    _nodeInversions.dispose();
    _nodeNotes.dispose();
    super.dispose();
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
        focusNode: _nodeName,
        onFieldSubmitted: (_) {
          _nodeName.unfocus();
          FocusScope.of(context).requestFocus(_nodeOpenYear);
        },
        decoration: submissionDecoration(
            labelText: "Name *", hintText: "Attraction Name"),
        initialValue: _data.attractionName,
        validator: (value) {
          if (value.isEmpty) {
            return "Please enter the name of the attraction";
          }
        },
        onSaved: (value) {
          _data.attractionName = value;
        },
      ),
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
      ),
      StringListField(
        onSaved: (d) {
          _data.formerNames = d;
        },
        initialValue: _data.formerNames,
        label: "Former Names",
        headerText: "Former Names",
        hintText: "Former Name [2001-2012]",

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
        focusNode: _nodeOpenYear,
        onFieldSubmitted: (_) {
          _nodeOpenYear.unfocus();
          if (_attractionStatus == AttractionStatus.DEFUNCT) {
            FocusScope.of(context).requestFocus(_nodeCloseYear);
          } else {
            FocusScope.of(context).requestFocus(_nodeManufacturer);
          }
        },
        initialValue: (_data.yearOpen != null && _data.yearOpen != 0)
            ? _data.yearOpen.toString()
            : "",
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
        },
        initialValue: _data.openingDay,
        text: (_attractionStatus == AttractionStatus.UPCOMING)
            ? "Date Opening"
            : "Date Opened",
      ),
      TextFormField(
        focusNode: _nodeCloseYear,
        onFieldSubmitted: (_) {
          _nodeCloseYear.unfocus();
          FocusScope.of(context).requestFocus(_nodeManufacturer);
        },
        initialValue: (_data.yearClosed != null && _data.yearClosed != 0)
            ? _data.yearClosed.toString()
            : "",
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
      ),
      StringListField(
        onSaved: (d) {
          _data.inactivePeriods = d;
        },
        initialValue: _data.inactivePeriods,
        label: "Years Inactive",
        headerText: "Years Inactive",
        hintText: "ex: 2008-2012",
      ),
      /*
      TextFormField(
        focusNode: _nodeInactive,
        onFieldSubmitted: (_) {
          _nodeInactive.unfocus();
          FocusScope.of(context)
              .requestFocus(_nodeManufacturer);
        },
        initialValue: _data.inactivePeriods,
        decoration: submissionDecoration(
          hintText: "ex. 2008-2016",
          labelText: "Years Inactive",
        ),
        onSaved: (value) {
          _data.inactivePeriods = value;
        },
      ),*/

      SubmissionDivider(),
    ];
  }

  List<Widget> _buildFactsAndStats(BuildContext context) {
    return <Widget>[
      TextFormField(
        focusNode: _nodeManufacturer,
        onFieldSubmitted: (_) {
          _nodeManufacturer.unfocus();
          FocusScope.of(context).requestFocus(_nodeModel);
        },
        initialValue: _data.manufacturer,
        decoration: submissionDecoration(
          hintText: "Manufacturer",
          labelText: "Manufacturer",
        ),
        onSaved: (value) {
          _data.manufacturer = value;
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
      ),
      TextFormField(
        focusNode: _nodeModel,
        onFieldSubmitted: (_) {
          _nodeModel.unfocus();
          FocusScope.of(context).requestFocus(_nodeHeight);
        },
        initialValue: _data.model,
        decoration: submissionDecoration(
          hintText: "Model",
          labelText: "Model",
        ),
        onSaved: (value) {
          _data.model = value;
        },
      ),
      TextFormField(
        focusNode: _nodeHeight,
        onFieldSubmitted: (_) {
          _nodeHeight.unfocus();
          FocusScope.of(context).requestFocus(_nodeMaxSpeed);
        },
        initialValue: (_data.height != null && _data.height != 0.0)
            ? _data.height.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Height",
          labelText: "Height",
          suffixText: "ft ",
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
        },
        onSaved: (value) {
          _data.height = num.tryParse(value);
        },
      ),
      TextFormField(
        focusNode: _nodeMaxSpeed,
        onFieldSubmitted: (_) {
          _nodeMaxSpeed.unfocus();
          FocusScope.of(context).requestFocus(_nodeLength);
        },
        initialValue: (_data.maxSpeed != null && _data.maxSpeed != 0.0)
            ? _data.maxSpeed.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Speed",
          labelText: "Max Speed",
          suffixText: "mph ",
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
        },
        onSaved: (value) {
          _data.maxSpeed = num.tryParse(value);
        },
      ),
      TextFormField(
        focusNode: _nodeLength,
        onFieldSubmitted: (_) {
          _nodeLength.unfocus();
          FocusScope.of(context).requestFocus(_nodeInversions);
        },
        initialValue: (_data.length != null && _data.length != 0.0)
            ? _data.length.toString()
            : "",
        decoration: submissionDecoration(
          hintText: "Length",
          labelText: "Length",
          suffixText: "ft ",
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
        },
        onSaved: (value) {
          _data.length = num.tryParse(value);
        },
      ),
      DurationPickerFormField(
        initialValue: Duration(seconds: _data.attractionDuration ?? 0),
        onSaved: (d) => _data.attractionDuration = d.inSeconds,
      ),
      TextFormField(
        focusNode: _nodeInversions,
        onFieldSubmitted: (_) {
          _nodeInversions.unfocus();
          FocusScope.of(context).requestFocus(_nodeNotes);
        },
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
        focusNode: _nodeNotes,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        initialValue: _data.notes,
        onSaved: (n) {
          _data.notes = n;
        },
        decoration: submissionDecoration(labelText: "Notes"),
      ),
    ];
  }
}
