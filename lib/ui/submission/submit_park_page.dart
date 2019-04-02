import 'package:flutter/material.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/widgets/forms/form_header.dart';
import 'package:log_ride/widgets/forms/proper_adaptive_switch.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/forms/submission_divider.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';

class SubmitParkPage extends StatefulWidget {
  @override
  _SubmitParkPageState createState() => _SubmitParkPageState();
}

class _SubmitParkPageState extends State<SubmitParkPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _parkTypesStrings = [
    "Theme Park",
    "Amusement Park",
    "Zoo",
    "Kiddie Park",
    "Family Entertainment Center",
    "Resort & Casino"
  ];

  List<DropdownMenuItem<String>> _parkTypesItems =
      List<DropdownMenuItem<String>>();

  BluehostPark _data;

  List<String> cityState = List<String>(2);
  bool _closedEnabled = false;

  @override
  void initState() {
    // Establish our park types for the dropdown
    _parkTypesStrings.forEach((s) {
      _parkTypesItems.add(DropdownMenuItem<String>(
        child: Text(s),
        value: s,
      ));
    });

    // Create our empty park
    _data = BluehostPark(id: null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            // The overall container is green so it stretches north past the status bar
            color: Theme.of(context).primaryColor,
            child: SafeArea(
                child: Container(
              // But the form's content has a white background
              color: Colors.white,
              child: Form(
                key: _formKey,
                autovalidate: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Header
                    FormHeader(text: "Suggest a New Park"),

                    // The container is padded on the sides, unlike the form header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children:
                            (<Widget>[]
                              ..addAll(_buildCoreInformation(context))
                              ..addAll(_buildLocationInformation(context))
                              ..addAll(_buildOperatingHistory(context))
                              ..addAll(_buildInternetInfo(context)))
                              .map((entry) {
                                return Padding(
                                  child: entry,
                                  padding: EdgeInsets.only(top: 4.0),
                                );
                              }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            ))),
      ),
      // Buttons used at the bottom of the screen (cancel & submit)
      persistentFooterButtons: <Widget>[
        InterfaceButton(
            text: "Cancel",
            onPressed: () => Navigator.of(context).pop(),
            color: UI_BUTTON_BACKGROUND,
            textColor: Colors.black),
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
        )
      ],
    );
  }

  List<Widget> _buildCoreInformation(BuildContext context) {
    return <Widget>[
      // Park Name
      TextFormField(
        decoration:
            submissionDecoration(labelText: "Name *", hintText: "Park Name"),
        initialValue: _data.parkName ?? "",
        validator: (value) {
          if (value.isEmpty) {
            return "Please enter the name of the park";
          }
        },
        onSaved: (value) {
          _data.parkName = value;
        },
      ),

      // Park Type
      FormField(
        initialValue: _parkTypesItems.first.value,
        onSaved: (v) {
          _data.type = v;
        },
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: submissionDecoration(
                hintText: "Type", labelText: "Park Type*"),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                    value: state.value,
                    onChanged: (value) {
                      state.didChange(value);
                    },
                    items: _parkTypesItems)),
          );
        },
      ),

      SubmissionDivider()
    ];
  }

  List<Widget> _buildLocationInformation(BuildContext context) {
    return <Widget>[
      // The city the park is located in
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
          hintText: "City",
          labelText: "City*"
        ),
        validator: (v) {
          if(v.isEmpty) {
            return "Please enter the city this park is located in";
          }
        },
        onSaved: (value) {
          cityState[0] = value;
          if(cityState[1] != null){
            _data.parkCity = "${cityState[0]}, ${cityState[1]}";
          }
        },
      ),

      // The state the park is located in
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
            hintText: "State/Province",
            labelText: "State/Province"
        ),
        onSaved: (value) {
          cityState[1] = value;
          if(cityState[0] != null){
            _data.parkCity = "${cityState[0]}, ${cityState[1]}";
          }
        },
      ),

      // Country the park is located in
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
          hintText: "Country",
          labelText: "Country*"
        ),
        onSaved: (value) {
          _data.parkCountry = value;
        },
        validator: (v) {
          if(v.isEmpty){
            return "Please enter the country the park is located in";
          }
        },
      ),

      // TODO --- GEOLOCATION / POSITION FIELD

      SubmissionDivider()
    ];
  }

  List<Widget> _buildOperatingHistory(BuildContext context) {
    return <Widget>[
      // Year opened
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
          hintText: "Year Opened",
          labelText: "Year Opened"
        ),
        onSaved: (v) {
          _data.yearOpen = num.tryParse(v) ?? 0;
        },
      ),

      // Year Closed
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
            hintText: "Year Closed",
            labelText: "Year Closed"
        ),
        enabled: _closedEnabled,
        onSaved: (v) {
          _data.yearClosed = num.tryParse(v) ?? 0;
        },
      ),

      // Defunct
      AdaptiveSwitchFormField(
        initialValue: !(_data.active ?? true),
        label: "Defunct",
        onSaved: (val) => _data.active = !val,
        onChanged: (v) => setState((){ _closedEnabled = v; }),
      ),

      // Seasonal
      AdaptiveSwitchFormField(
        initialValue: _data.seasonal ?? false,
        label: "Seasonal",
        onSaved: (val) => _data.seasonal = val,
      ),

      // Previous Names
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
            hintText: "Previous Names",
            labelText: "Previous Name(s)"
        ),
        onSaved: (v) {
          _data.previousNames = v;
        },
      ),

      SubmissionDivider()
    ];
  }

  List<Widget> _buildInternetInfo(BuildContext context) {
    return <Widget>[
      // Website URL
      TextFormField(
        initialValue: "",
        decoration: submissionDecoration(
            hintText: "URL",
            labelText: "Website URL"
        ),
        onSaved: (v) {
          _data.website = v;
        },
      ),

    ];
  }
}
