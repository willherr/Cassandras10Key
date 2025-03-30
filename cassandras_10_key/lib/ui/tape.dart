import 'package:adding_machine/app_state.dart';
import 'package:adding_machine/util/history_model.dart';
import 'package:adding_machine/ui/edit_history_dialog.dart';
import 'package:adding_machine/util/round.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Tape extends StatefulWidget {
  const Tape(this.appState, {Key? key}) : super(key: key);

  final AppState appState;

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> {
  @override
  Widget build(BuildContext context) {
    DateTime? lastDate;

    return SingleChildScrollView(
      reverse: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.appState.history.expand((h) {
          var widgets = [
            h.widget(() => _editHistory(
                h.value, widget.appState.history.toList().indexOf(h))),
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
    );
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
      var newTotal = round((widget.appState.runningTotal ?? 0) + difference);

      setState(() {
        widget.appState.history[index] = History(
          value: newValue,
          isTotal: widget.appState.history[index].isTotal,
          isClear: widget.appState.history[index].isClear,
        );

        for (++index; index < widget.appState.history.length; index++) {
          if (widget.appState.history[index].isClear) {
            updateRunningTotal = false;
            break;
          }
          if (!widget.appState.history[index].isTotal) continue;

          newTotal = round(difference + widget.appState.history[index].value);

          widget.appState.history[index] = History(
            value: newTotal,
            isTotal: widget.appState.history[index].isTotal,
            isClear: widget.appState.history[index].isClear,
          );
        }

        if (updateRunningTotal) {
          widget.appState.runningTotal = newTotal;
        }

        if (updateRunningTotal ||
            widget
                .appState.history[widget.appState.history.length - 1].isTotal) {
          widget.appState.currentValue = newTotal.toString();

          if (widget.appState.currentValue.endsWith(".0")) {
            widget.appState.currentValue =
                widget.appState.currentValue.substring(
              0,
              widget.appState.currentValue.length - 2,
            );
          }

          widget.appState.setCurrentDisplay();
        }
      });
    }
  }
}
