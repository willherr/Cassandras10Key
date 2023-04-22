import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'material_text_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffold = GlobalKey<ScaffoldState>();

  String _currentDisplay = "0";

  double? _runningTotal;
  String? _lastInput;

  bool _lastActionWasAFunction = false;
  String _lastAction = "";

  final List<Widget> _history = [];

  String get input => _lastInput != null && _lastActionWasAFunction
      ? _lastInput!
      : _currentDisplay;

  @override
  Widget build(BuildContext context) {
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
      MaterialTextButton("←", warn: true, onPressed: () => _backSpace()),
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
      MaterialTextButton(".", onPressed: () => _appendToNumber('.')),
    ];

    final buttons = [
      ...clearButtons,
      ...functionButtons,
      ...numberButtons,
    ];

    final rows = <Row>[];
    Row row = Row();

    for (var i = 0; i < buttons.length; i++) {
      if (i % 3 == 0) {
        row = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [],
        );
        rows.add(row);
      }

      row.children.add(Expanded(child: buttons[i]));
    }

    return Scaffold(
      key: _scaffold,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () => _onLongPressDisplay(context, true),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _history,
                    ),
                  ),
                ),
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
        _addHistory(const Divider(
          color: Colors.red,
          indent: 50,
          endIndent: 50,
        ));
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

      _addHistory(SelectableText.rich(TextSpan(
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
      )));

      _currentDisplay = historyDisplay;

      _lastInput = historyDisplay.startsWith("-")
          ? historyDisplay.substring(1)
          : historyDisplay;

      _runningTotal = null;

      _addHistory(const Divider(
        color: Colors.green,
        indent: 50,
        endIndent: 50,
      ));
    });
  }

  _add([String? input]) {
    // if the user did an add or subtract
    _lastInput = input ?? this.input;
    final currentValue = double.parse(_lastInput!);

    setState(() {
      // history
      if (_lastInput!.startsWith("-")) {
        _addHistory(SelectableText.rich(TextSpan(
          children: [
            TextSpan(text: _lastInput!.substring(1)),
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
        )));
      } else {
        _addHistory(SelectableText.rich(TextSpan(
          children: [
            TextSpan(text: _lastInput),
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
        )));
      }

      // running total
      if (_runningTotal == null) {
        _runningTotal = currentValue;
      } else {
        _runningTotal = currentValue + _runningTotal!;
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

    if (!mounted) return;

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
                    setState(() => _history.clear());
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

  _addHistory(Widget widget) {
    setState(() => _history.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget,
        )));
  }
}
