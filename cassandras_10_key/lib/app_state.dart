import 'dart:convert';
import 'dart:io';

import 'package:adding_machine/util/history_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AppState {
  AppState._create(this.history, [this.historyFile]);

  final List<History> history;
  final File? historyFile;

  String currentValue = "0";
  String currentDisplay = "0";

  double? runningTotal;
  String? lastInput;

  bool lastActionWasAFunction = false;

  String get input =>
      lastInput != null && lastActionWasAFunction ? lastInput! : currentValue;

  static Future<AppState> get() async {
    if (kIsWeb) return AppState._create([]);

    var tempDirectory = await getTemporaryDirectory();

    var historyFile = File('${tempDirectory.path}/history.json');

    var historyFileContents = await historyFile.exists()
        ? (await historyFile.readAsString()).trim()
        : null;

    var history = historyFileContents != null && historyFileContents != ""
        ? historyFileContents
            .split(Platform.lineTerminator)
            .map((json) => History.fromJson(jsonDecode(json)))
            .toList()
        : <History>[];

    return AppState._create(history, historyFile);
  }

  addHistory(History h) async {
    history.add(h);
    await _saveHistory();
  }

  clearHistory() async {
    history.clear();
    await _saveHistory();
  }

  setCurrentDisplay() {
    final numberParts = currentValue.split(".");
    final wholeNumber = int.parse(numberParts[0]);
    final fractionPart = numberParts.length > 1 ? ".${numberParts[1]}" : "";

    currentDisplay = "${NumberFormat.decimalPattern().format(
      wholeNumber,
    )}$fractionPart";
  }

  _saveHistory() async {
    await historyFile?.writeAsString(
      history.map((h) => jsonEncode(h)).join(Platform.lineTerminator),
    );
  }
}
