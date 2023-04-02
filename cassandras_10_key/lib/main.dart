import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _scaffold = GlobalKey<ScaffoldState>();

  String _currentDisplay = "0";

  double get _currentValue => double.parse(_currentDisplay);
  double? _runningTotal;

  bool _lastActionWasAFunction = false;

  final List<String> _history = [];

  @override
  Widget build(BuildContext context) {
    final clearButtons = [
      MaterialTextButton("C", warn: true, onPressed: () => _clearNumber(true)),
      MaterialTextButton("CE",
          warn: true, onPressed: () => _clearNumber(false)),
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
          // ignore: prefer_const_literals_to_create_immutables
          children: [],
        );
        rows.add(row);
      }

      row.children.add(Expanded(child: buttons[i]));
    }

    return Scaffold(
      key: _scaffold,
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
                          child: SelectableText(
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
                GestureDetector(
                  onLongPress: () async => await _onLongPressDisplay(context),
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
                      style: const TextStyle(fontSize: 24.0),
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
        _runningTotal = null;
        _history.add("-----------------------");
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
      _history.add("$historyDisplay T");
    });
  }

  _add() {
    setState(() {
      // history
      if (_currentDisplay.startsWith("-")) {
        _history.add("${_currentDisplay.substring(1)} -");
      } else {
        _history.add("$_currentDisplay +");
      }

      // running total
      if (_runningTotal == null) {
        _runningTotal = _currentValue;
      } else {
        _runningTotal = _currentValue + _runningTotal!;
      }

      _currentDisplay = _runningTotal.toString();

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
    if (_currentDisplay.startsWith("-")) {
      _currentDisplay = _currentDisplay.substring(1);
    } else {
      _currentDisplay = "-$_currentDisplay";
    }

    _add();
  }

  _onLongPressDisplay(BuildContext context) async {
    final clipboard = await Clipboard.getData("text/plain");

    if (!mounted) return;

    showModalBottomSheet(
        context: context,
        constraints: const BoxConstraints.tightFor(height: 150),
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialTextButton("Copy", onPressed: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: _currentDisplay));
              }),
              MaterialTextButton(
                "Paste",
                onPressed: clipboard?.text == null ||
                        double.tryParse(clipboard!.text!) == null
                    ? null
                    : () {
                        setState(() => _currentDisplay = clipboard.text!);
                        Navigator.pop(context);
                      },
              ),
            ],
          );
        });
  }
}
