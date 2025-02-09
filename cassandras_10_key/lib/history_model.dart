import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_model.g.dart';

// see: https://www.kindacode.com/article/dart-ways-to-convert-a-class-instance-to-json#using-json_serializable-package
// for building JSON models

// note: if new properties are added, run the following command:
//       dart run build_runner build

@JsonSerializable()
class History {
  History({
    this.value = 0,
    this.isTotal = false,
    this.isClear = false,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  final double value;
  final bool isTotal;
  final bool isClear;
  final DateTime createdDate;

  Widget widget(Function editHistory) {
    if (isClear) {
      if (isTotal) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.green,
            indent: 50,
            endIndent: 50,
          ),
        );
      }

      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Divider(
          color: Colors.red,
          indent: 50,
          endIndent: 50,
        ),
      );
    }

    if (isTotal) {
      var historyDisplay = value.toString();

      if (historyDisplay.endsWith(".0")) {
        historyDisplay = historyDisplay.substring(0, historyDisplay.length - 2);
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(text: historyDisplay),
              TextSpan(
                text: " T",
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      var currentValueDisplay = value.toString();
      if (currentValueDisplay.endsWith(".0")) {
        currentValueDisplay = currentValueDisplay.substring(
          0,
          currentValueDisplay.length - 2,
        );
      }

      Widget history;

      if (value < 0) {
        history = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currentValueDisplay.substring(1),
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: " -",
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      } else {
        history = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: currentValueDisplay,
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: " +",
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      }

      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: history,
        ),
        onLongPress: () => editHistory(),
        onDoubleTap: () => editHistory(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$HistoryToJson(this);
  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);
}
