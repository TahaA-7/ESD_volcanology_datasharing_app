import 'package:flutter/material.dart';

extension StringExtensions on String {
  String title() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  bool get isNumeric => double.tryParse(this) != null;

  bool isLessThan(int? y) {
    if (y != null && isNumeric) {  // the same as `&& this.isNumeric`
      // Parse 'this' to a number before comparing
      return (double.parse(this)) < y;
    }
    return false; // Default return if types don't match or y is null
  }

  int _getInt(String s) => s.isNumeric ? int.parse(s) : throw FormatException("$s is not a number. ");
}
