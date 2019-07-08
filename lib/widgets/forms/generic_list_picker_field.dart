import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/widgets/dialogs/generic_list_picker.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';

class GenericListPickerFormField<T> extends StatelessWidget {
  GenericListPickerFormField(this.list,
      {this.onSaved,
      this.onUpdate,
      this.validator,
      this.initialValue,
      this.valueBuilder,
      this.pickerBuilder,
      this.label = "List",
      this.enabled = true});

  final List<T> list;
  final Function onSaved;
  final Function onUpdate;
  final Function validator;
  final T initialValue;
  final String label;
  final bool enabled;

  final String Function(BuildContext context, T entry) valueBuilder;
  final Widget Function(BuildContext context, List<T> list) pickerBuilder;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: submissionDecoration(enabled: enabled),
      child: FormField<T>(
        initialValue: initialValue,
        onSaved: (d) => onSaved(d),
        enabled: enabled,
        validator: (v) {
          if (validator != null) validator(v);
        },
        builder: (FormFieldState<T> state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (!enabled) return;

              dynamic result = await showDialog(
                  context: context,
                  builder: (pickerBuilder != null)
                      ? (BuildContext context) => pickerBuilder(context, list)
                      : (BuildContext context) => GenericListPicker(list));

              if (result == null) return;
              T m = result as T;

              if (m != state.value) {
                state.didChange(m);
                if (onUpdate != null) {
                  onUpdate(m);
                }
              }
            },
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.title.apply(
                        fontWeightDelta: -1,
                        color: enabled ? Colors.grey[700] : Colors.grey[350]),
                  ),
                  Expanded(
                    child: AutoSizeText(
                        (state.value != null)
                            ? (valueBuilder != null)
                                ? valueBuilder(context, state.value)
                                : state.value.toString()
                            : "",
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.title.apply(
                            fontWeightDelta: -1,
                            color: enabled
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5))),
                  ),
                  if (state.value != null)
                    IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          state.didChange(null);
                          if (onUpdate != null) onUpdate(null);
                        }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ManufacturerPickerFormField extends StatelessWidget {
  ManufacturerPickerFormField(this.list,
      {this.onSaved,
      this.onUpdate,
      this.validator,
      this.initialValue,
      this.enabled = true});

  final List<Manufacturer> list;
  final Function(Manufacturer m) onSaved;
  final Function(Manufacturer m) onUpdate;
  final Function validator;
  final Manufacturer initialValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GenericListPickerFormField<Manufacturer>(
      list,
      onSaved: (Manufacturer value) {
        if (onSaved != null) onSaved(value);
      },
      onUpdate: (Manufacturer value) {
        if (onUpdate != null) onUpdate(value);
      },
      validator: validator,
      initialValue: initialValue,
      enabled: enabled,
      label: "Manufacturer",
      valueBuilder: (BuildContext context, Manufacturer entry) {
        return entry.name;
      },
      pickerBuilder: (BuildContext context, List<Manufacturer> list) {
        return ManufacturerPicker(manufacturers: list);
      },
    );
  }
}

class ModelPickerFormField extends StatelessWidget {
  ModelPickerFormField(this.list,
      {this.onSaved,
      this.onUpdate,
      this.validator,
      this.initialValue,
      this.enabled = true});

  final List<Model> list;
  final Function(Model m) onSaved;
  final Function(Model m) onUpdate;
  final Function validator;
  final Model initialValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GenericListPickerFormField<Model>(
      list,
      onSaved: (Model value) {
        if (onSaved != null) onSaved(value);
      },
      onUpdate: (Model value) {
        if (onUpdate != null) onUpdate(value);
      },
      validator: validator,
      initialValue: initialValue,
      enabled: enabled,
      label: "Model",
      valueBuilder: (BuildContext context, Model entry) {
        return entry.name;
      },
      pickerBuilder: (BuildContext context, List<Model> list) {
        return ModelPicker(models: list);
      },
    );
  }
}
