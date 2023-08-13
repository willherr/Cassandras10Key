import 'package:flutter/material.dart';

class History {
  History({
    required this.value,
    required this.widget,
    this.isTotal = false,
    this.isClear = false,
  });

  final double value;
   Widget widget;
  final bool isTotal;
  final bool isClear;
}
