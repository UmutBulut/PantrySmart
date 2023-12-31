

import 'package:flutter/material.dart';

class PantryDatePicker extends StatefulWidget {
   PantryDatePicker({
    super.key,
    this.restorationId,
    required this.notifyParent,
    required this.dateString,
    required this.buttonLabel,
   required this.resettato});

  final String? restorationId;
  final Function(DateTime res) notifyParent;
  final String buttonLabel;
  String dateString = "";
  bool resettato;

  @override
  State<PantryDatePicker> createState() => _PantryDatePickerState();
}

class _PantryDatePickerState extends State<PantryDatePicker>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate =
  RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
  RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
      BuildContext context,
      Object? arguments,
      ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2021),
          lastDate: DateTime(2025),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        widget.notifyParent(_selectedDate.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                ),
                onPressed: () {
                  _restorableDatePickerRouteFuture.present();
                },
                icon: Icon( // <-- Icon
                  Icons.calendar_month_sharp,
                  size: 24.0,
                ),
                label: Text(
                    widget.buttonLabel
                ), // <-- Text
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                child: (!widget.resettato)?
                Text(_selectedDate.value.toString().substring(0,10),
                style: TextStyle(
                  fontSize: 17,
                ),):
                Text('Nessuna data\nselezionata.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}