import 'dart:convert';
import 'dart:io';

import 'package:adding_machine/history_model.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppSettings {
  AppSettings._create(this.history, [this.historyFile]);

  final List<History> history;
  final File? historyFile;

  static Future<AppSettings> get() async {
    if (kIsWeb) return AppSettings._create([]);

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

    return AppSettings._create(history, historyFile);
  }

  addHistory(History h) async {
    history.add(h);
    await _saveHistory();
  }

  clearHistory() async {
    history.clear();
    await _saveHistory();
  }

  _saveHistory() async {
    await historyFile?.writeAsString(
        history.map((h) => jsonEncode(h)).join(Platform.lineTerminator));
  }
}
