import 'package:flutter/material.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';

enum AttractionStatus { ACTIVE, DEFUNCT, UPCOMING }

class RideStatusDropdown extends StatelessWidget {
  RideStatusDropdown({this.initialValue, this.onSaved, this.onChanged});

  final BluehostAttraction initialValue;
  final Function(AttractionStatus) onSaved;
  final Function(AttractionStatus) onChanged;

  final List<DropdownMenuItem<AttractionStatus>> attractionStatus =
      <DropdownMenuItem<AttractionStatus>>[
    DropdownMenuItem(
      child: Text("Active"),
      value: AttractionStatus.ACTIVE,
    ),
    DropdownMenuItem(
      child: Text("Defunct"),
      value: AttractionStatus.DEFUNCT,
    ),
    DropdownMenuItem(
      child: Text("Coming Soon"),
      value: AttractionStatus.UPCOMING,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: getAttractionStateFromBluehostAttraction(initialValue),
      onSaved: (v) {
        onSaved(v);
      },
      builder: (FormFieldState<AttractionStatus> state) {
        return InputDecorator(
          decoration: submissionDecoration(
              hintText: "Attraction Status", labelText: "Status *"),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AttractionStatus>(
              value: state.value,
              onChanged: (value) {
                state.didChange(value);
                onChanged(value);
              },
              items: attractionStatus,
            ),
          ),
        );
      },
    );
  }
}

BluehostAttraction applyStatusToAttraction(
    AttractionStatus status, BluehostAttraction attr) {
  switch (status) {
    case AttractionStatus.ACTIVE:
      attr.active = true;
      break;
    case AttractionStatus.UPCOMING:
      attr.upcoming = true;
      break;
    case AttractionStatus.DEFUNCT:
      attr.active = false;
      break;
  }

  return attr;
}

AttractionStatus getAttractionStateFromBluehostAttraction(
    BluehostAttraction attraction) {
  // Defunct attractions take priority
  if (!attraction.active) {
    return AttractionStatus.DEFUNCT;
  }
  // With upcoming attractions coming next
  if (attraction.upcoming) {
    return AttractionStatus.UPCOMING;
  }

  // Finally, the base state of an attraction, active
  return AttractionStatus.ACTIVE;
}
