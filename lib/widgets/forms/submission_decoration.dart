import 'package:flutter/material.dart';

InputDecoration submissionDecoration(
    {String hintText, String labelText, String suffixText, bool enabled = true}) {
  return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixText: suffixText,
      enabled: enabled,
      border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
      filled: true);
}
