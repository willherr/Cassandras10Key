import 'dart:ui';

import 'package:adding_machine/app_state.dart';
import 'package:adding_machine/util/history_model.dart';
import 'package:adding_machine/ui/tape.dart';
import 'package:adding_machine/util/round.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/material_text_button.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e) {
    debugPrint("WidgetsFlutterBinding: $e");
  }

  try {
    if (!kIsWeb) {
      DartPluginRegistrant.ensureInitialized();
    }
  } catch (e) {
    debugPrint("DartPluginRegistrant: $e");
  }

  runApp(MyApp(await AppState.get()));
}

class MyApp extends StatelessWidget {
  const MyApp(this.appState, {super.key});

  final AppState appState;

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
      home: MyHomePage(appState),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.appState, {super.key});

  final AppState appState;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool get allowDualScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape &&
          MediaQuery.of(context).displayFeatures.any((df) =>
              df.type == DisplayFeatureType.fold ||
              df.type == DisplayFeatureType.hinge) ||
      MediaQuery.of(context).size.width > 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      MaterialTextButton("⬅️", warn: true, onPressed: () => _backSpace()),
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
                      widget.appState.currentDisplay,
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
    return GestureDetector(
      onLongPress: () => _onLongPressDisplay(context, true),
      child: Tape(widget.appState),
    );
  }

  _appendToNumber(String value) {
    if (widget.appState.lastActionWasAFunction) {
      _clearNumber(false);
      widget.appState.lastActionWasAFunction = false;
    }

    if (value == "." && widget.appState.currentValue.contains(".")) return;

    if (widget.appState.currentValue == "0" && value != ".") {
      widget.appState.currentValue = value;
    } else {
      widget.appState.currentValue += value;
    }

    setState(() => widget.appState.setCurrentDisplay());
  }

  _clearNumber(bool andLastValue) {
    setState(() {
      widget.appState.currentValue = "0";

      widget.appState.setCurrentDisplay();

      if (andLastValue) {
        widget.appState.runningTotal = null;
        widget.appState.lastInput = null;
        _addHistory(History(isClear: true));
      }
    });
  }

  _backSpace() {
    if (widget.appState.currentValue == "0" ||
        widget.appState.lastActionWasAFunction) {
      return;
    }

    widget.appState.currentValue = widget.appState.currentValue
        .substring(0, widget.appState.currentValue.length - 1);
    if (widget.appState.currentValue.isEmpty) {
      widget.appState.currentValue = "0";
    }

    setState(() => widget.appState.setCurrentDisplay());
  }

  _equals() {
    if (widget.appState.runningTotal == null) return;

    var historyDisplay = widget.appState.runningTotal.toString();

    if (historyDisplay.endsWith(".0")) {
      historyDisplay = historyDisplay.substring(0, historyDisplay.length - 2);
    }

    setState(() {
      widget.appState.lastActionWasAFunction = true;

      _addHistory(History(value: widget.appState.runningTotal!, isTotal: true));

      widget.appState.currentValue = historyDisplay;

      widget.appState.setCurrentDisplay();

      widget.appState.lastInput = historyDisplay.startsWith("-")
          ? historyDisplay.substring(1)
          : historyDisplay;

      widget.appState.runningTotal = null;

      _addHistory(History(isClear: true, isTotal: true));
    });
  }

  _add([String? input]) {
    // if the user did an add or subtract
    widget.appState.lastInput = input ?? widget.appState.input;
    final currentValue = double.parse(widget.appState.lastInput!);

    setState(() {
      // history
      _addHistory(History(value: currentValue));

      // running total
      if (widget.appState.runningTotal == null) {
        widget.appState.runningTotal = currentValue;
      } else {
        widget.appState.runningTotal =
            round(currentValue + widget.appState.runningTotal!);
      }

      widget.appState.currentValue = widget.appState.runningTotal.toString();

      if (widget.appState.currentValue.endsWith(".0")) {
        widget.appState.currentValue = widget.appState.currentValue.substring(
          0,
          widget.appState.currentValue.length - 2,
        );
      }

      widget.appState.setCurrentDisplay();

      widget.appState.lastActionWasAFunction = true;

      if (widget.appState.lastInput!.startsWith("-")) {
        widget.appState.lastInput = widget.appState.lastInput!
            .substring(1); // don't persist negative inputs
      }
    });
  }

  _subtract() {
    if (widget.appState.input.startsWith("-")) {
      _add(widget.appState.input.substring(1));
    } else {
      _add("-${widget.appState.input}");
    }
  }

  _addHistory(History history) async {
    setState(() {
      widget.appState.addHistory(history);
    });
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
                    widget.appState.clearHistory();
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
                      ClipboardData(text: widget.appState.currentValue));
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
                        widget.appState.currentValue = clipboard.text!;

                        widget.appState.setCurrentDisplay();

                        Navigator.pop(context);
                      },
                fontSize: 18,
              ),
          ],
        );
      },
    );
  }
}
