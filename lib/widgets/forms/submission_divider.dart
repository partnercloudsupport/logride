import 'package:flutter/material.dart';

class SubmissionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        height: 1.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0), color: Colors.black26),
      ),
    );
  }
}
