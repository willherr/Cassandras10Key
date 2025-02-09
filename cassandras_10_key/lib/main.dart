import 'dart:ui';

import 'package:adding_machine/app_settings_model.dart';
import 'package:adding_machine/edit_history_dialog.dart';
import 'package:adding_machine/history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'material_text_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(MyApp(await AppSettings.get()));
}

class MyApp extends StatelessWidget {
  const MyApp(this.appSettings, {super.key});

  final AppSettings appSettings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '10-Key Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.green,
          errorColor: Colors.red,
        ),
      ),
      home: MyHomePage(appSettings),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.appSettings, {super.key});

  final AppSettings appSettings;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffold = GlobalKey<ScaffoldState>();

  String _currentDisplay = "0";

  double? _runningTotal;
  String? _lastInput;

  bool _lastActionWasAFunction = false;

  String get input => _lastInput != null && _lastActionWasAFunction
      ? _lastInput!
      : _currentDisplay;

  bool get allowDualScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape &&
          MediaQuery.of(context).displayFeatures.any((df) =>
              df.type == DisplayFeatureType.fold ||
              df.type == DisplayFeatureType.hinge) ||
      MediaQuery.of(context).size.width > 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _mainWidget()),
            if (allowDualScreen) Expanded(child: _tapeWidget()),
          ],
        ),
      ),
    );
  }

  _mainWidget() {
    final clearButtons = [
      MaterialTextButton(
        "C",
        warn: true,
        onPressed: () => _clearNumber(true),
      ),
      MaterialTextButton(
        "CE",
        warn: true,
        onPressed: () => _clearNumber(false),
      ),
      MaterialTextButton("⬅", warn: true, onPressed: () => _backSpace()),
    ];

    final functionButtons = [
      Container(),
      MaterialTextButton("—", accent: true, onPressed: () => _subtract()),
      MaterialTextButton("+", accent: true, onPressed: () => _add()),
    ];

    final numberButtons = [
      // numbers
      MaterialTextButton("7", onPressed: () => _appendToNumber('7')),
      MaterialTextButton("8", onPressed: () => _appendToNumber('8')),
      MaterialTextButton("9", onPressed: () => _appendToNumber('9')),
      MaterialTextButton("4", onPressed: () => _appendToNumber('4')),
      MaterialTextButton("5", onPressed: () => _appendToNumber('5')),
      MaterialTextButton("6", onPressed: () => _appendToNumber('6')),
      MaterialTextButton("1", onPressed: () => _appendToNumber('1')),
      MaterialTextButton("2", onPressed: () => _appendToNumber('2')),
      MaterialTextButton("3", onPressed: () => _appendToNumber('3')),
      Container(),
      MaterialTextButton("0", onPressed: () => _appendToNumber('0')),
      MaterialTextButton("•", onPressed: () => _appendToNumber('.')),
    ];

    final buttons = [
      ...clearButtons,
      ...functionButtons,
      ...numberButtons,
    ];

    final rows = <Row>[];

    // ignore: prefer_const_constructors - breaks on line row.children.add(Expanded(child: buttons[i]));
    Row row = Row();

    for (var i = 0; i < buttons.length; i++) {
      if (i % 3 == 0) {
        // ignore: prefer_const_constructors
        row = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [],
        );
        rows.add(row);
      }

      row.children.add(Expanded(child: buttons[i]));
    }

    return Center(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: allowDualScreen ? Container() : _tapeWidget(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onLongPress: () => _onLongPressDisplay(context, false),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey),
                      ),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    margin: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _currentDisplay,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 32.0),
                    ),
                  ),
                ),
                Column(
                  children: [
                    ...rows,
                    Row(
                      children: [
                        Expanded(
                          child: MaterialTextButton(
                            "=",
                            accent: true,
                            onPressed: () => _equals(),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _tapeWidget() {
    DateTime? lastDate;

    return GestureDetector(
      onLongPress: () => _onLongPressDisplay(context, true),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.appSettings.history.expand((h) {
            var widgets = [
              h.widget(() => _editHistory(
                  h.value, widget.appSettings.history.toList().indexOf(h))),
            ];

            var historyDate = DateTime(
              h.createdDate.year,
              h.createdDate.month,
              h.createdDate.day,
            );

            if (historyDate != lastDate) {
              var formattedDate = DateFormat.yMMMMd().format(historyDate);

              if (historyDate.year == DateTime.now().year) {
                var now = DateTime.now();
                now = DateTime(now.year, now.month, now.day);

                if (historyDate == now) {
                  formattedDate = "Today";
                } else if (historyDate == now.add(const Duration(days: -1))) {
                  formattedDate = "Yesterday";
                } else {
                  formattedDate = DateFormat.MMMMd().format(historyDate);
                }
              }

              widgets.insert(
                0,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 125, 125, 125),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );

              lastDate = historyDate;
            }

            return widgets;
          }).toList(),
        ),
      ),
    );
  }

  _appendToNumber(String value) {
    if (_lastActionWasAFunction) {
      _clearNumber(false);
      _lastActionWasAFunction = false;
    }

    if (value == "." && _currentDisplay.contains(".")) return;

    if (_currentDisplay == "0" && value != ".") {
      _currentDisplay = "";
    }

    setState(() => _currentDisplay += value);
  }

  _clearNumber(bool andLastValue) {
    setState(() {
      _currentDisplay = "0";

      if (andLastValue) {
        _runningTotal = null;
        _lastInput = null;
        _addHistory(History(isClear: true));
      }
    });
  }

  _backSpace() {
    if (_currentDisplay == "0" || _lastActionWasAFunction) return;

    setState(() {
      _currentDisplay =
          _currentDisplay.substring(0, _currentDisplay.length - 1);
      if (_currentDisplay.isEmpty) _currentDisplay = "0";
    });
  }

  _equals() {
    if (_runningTotal == null) return;

    var historyDisplay = _runningTotal.toString();

    if (historyDisplay.endsWith(".0")) {
      historyDisplay = historyDisplay.substring(0, historyDisplay.length - 2);
    }

    setState(() {
      _lastActionWasAFunction = true;

      _addHistory(History(value: _runningTotal!, isTotal: true));

      _currentDisplay = historyDisplay;

      _lastInput = historyDisplay.startsWith("-")
          ? historyDisplay.substring(1)
          : historyDisplay;

      _runningTotal = null;

      _addHistory(History(isClear: true, isTotal: true));
    });
  }

  _add([String? input]) {
    // if the user did an add or subtract
    _lastInput = input ?? this.input;
    final currentValue = double.parse(_lastInput!);

    setState(() {
      // history
      _addHistory(History(value: currentValue));

      // running total
      if (_runningTotal == null) {
        _runningTotal = currentValue;
      } else {
        _runningTotal = _round(currentValue + _runningTotal!);
      }

      _currentDisplay = _runningTotal.toString();

      if (_currentDisplay.endsWith(".0")) {
        _currentDisplay = _currentDisplay.substring(
          0,
          _currentDisplay.length - 2,
        );
      }

      _lastActionWasAFunction = true;

      if (_lastInput!.startsWith("-")) {
        _lastInput = _lastInput!.substring(1); // don't persist negative inputs
      }
    });
  }

  _subtract() {
    if (input.startsWith("-")) {
      _add(input.substring(1));
    } else {
      _add("-$input");
    }
  }

  _onLongPressDisplay(BuildContext context, bool fromHistory) async {
    final clipboard = await Clipboard.getData("text/plain");

    if (!mounted || !context.mounted) return;

    showModalBottomSheet(
        context: context,
        constraints: BoxConstraints.tightFor(height: fromHistory ? 75 : 150),
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (fromHistory)
                MaterialTextButton(
                  "Clear History",
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      widget.appSettings.clearHistory();
                    });
                  },
                  fontSize: 18,
                ),
              if (!fromHistory)
                MaterialTextButton(
                  "Copy Number to Clipboard",
                  onPressed: () async {
                    Navigator.pop(context);
                    await Clipboard.setData(
                        ClipboardData(text: _currentDisplay));
                  },
                  fontSize: 18,
                ),
              if (!fromHistory)
                MaterialTextButton(
                  "Paste Number from Clipboard",
                  onPressed: clipboard?.text == null ||
                          double.tryParse(clipboard!.text!) == null
                      ? null
                      : () {
                          setState(() => _currentDisplay = clipboard.text!);
                          Navigator.pop(context);
                        },
                  fontSize: 18,
                ),
            ],
          );
        });
  }

  _addHistory(History history) async {
    setState(() {
      widget.appSettings.addHistory(history);
    });
  }

  _editHistory(double value, int index) async {
    double newValue = await showDialog(
          context: context,
          builder: (context) => EditHistoryDialog(initialValue: value),
        ) ??
        value;

    var difference = newValue - value;

    if (difference != 0) {
      var updateRunningTotal = true;
      var newTotal = _round((_runningTotal ?? 0) + difference);

      setState(() {
        widget.appSettings.history[index] = History(
          value: newValue,
          isTotal: widget.appSettings.history[index].isTotal,
          isClear: widget.appSettings.history[index].isClear,
        );

        for (++index; index < widget.appSettings.history.length; index++) {
          if (widget.appSettings.history[index].isClear) {
            updateRunningTotal = false;
            break;
          }
          if (!widget.appSettings.history[index].isTotal) continue;

          newTotal =
              _round(difference + widget.appSettings.history[index].value);

          widget.appSettings.history[index] = History(
            value: newTotal,
            isTotal: widget.appSettings.history[index].isTotal,
            isClear: widget.appSettings.history[index].isClear,
          );
        }

        if (updateRunningTotal) {
          _runningTotal = newTotal;
        }

        if (updateRunningTotal ||
            widget.appSettings.history[widget.appSettings.history.length - 1]
                .isTotal) {
          _currentDisplay = newTotal.toString();

          if (_currentDisplay.endsWith(".0")) {
            _currentDisplay = _currentDisplay.substring(
              0,
              _currentDisplay.length - 2,
            );
          }
        }
      });
    }
  }

  double _round(double value, {double precision = 100000000}) {
    return (value * precision).round() / precision;
  }
}
