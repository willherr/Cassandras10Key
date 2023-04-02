import 'package:flutter/material.dart';

import 'material_text_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cassandra\'s 10-Key',
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
  String _currentDisplay = "0";

  double get _currentValue => double.parse(_currentDisplay);
  double? _lastValue;

  bool _lastActionWasAFunction = false;

  final List<String> _history = [
    "1 +",
    "2 +",
    "3 -",
    "4 +",
    "1 +",
    "2 +",
    "3 -",
    "4 +",
    "1 +",
    "2 +",
    "3 -",
    "4 +"
  ];

  @override
  Widget build(BuildContext context) {
    final clearButtons = [
      MaterialTextButton("C", warn: true, onPressed: () => _clearNumber(false)),
      MaterialTextButton("CE", warn: true, onPressed: () => _clearNumber(true)),
      MaterialTextButton("←", warn: true, onPressed: () => _backSpace()),
    ];

    final functionButtons = [
      Container(),
      MaterialTextButton("-", accent: true, onPressed: () => _subtract()),
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
          children: [],
        );
        rows.add(row);
      }

      row.children.add(Expanded(child: buttons[i]));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cassandra\'s 10-Key'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _history
                      .map<Widget>(
                        (text) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.black),
                    ),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _currentDisplay,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
                Column(
                  children: [...rows],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _appendToNumber(String value) {
    if (_lastActionWasAFunction) _clearNumber(false);

    if (value == "." && _currentDisplay.contains(".")) return;

    if (_currentDisplay == "0" && value != ".") {
      _currentDisplay = "";
    }

    setState(() => _currentDisplay += value);
  }

  _clearNumber(bool andLastValue) {
    setState(() {
      _lastActionWasAFunction = false;
      _currentDisplay = "0";

      if (andLastValue) {
        _lastValue = null;
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

  _add() {
    setState(() {
      if (_lastValue == null) {
        _lastValue = _currentValue;
      } else {
        _lastValue = _currentValue + _lastValue!;
      }

      _currentDisplay = _lastValue.toString();

      if (_currentDisplay.endsWith(".0")) {
        _currentDisplay = _currentDisplay.substring(
          0,
          _currentDisplay.length - 2,
        );
      }

      _lastActionWasAFunction = true;
    });
  }

  _subtract() {
    _currentDisplay = "-$_currentDisplay";
    _add();
  }
}
