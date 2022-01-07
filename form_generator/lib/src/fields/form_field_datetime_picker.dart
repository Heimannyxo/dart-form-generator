import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormFieldDateTimePicker extends StatefulWidget {
  final String label;
  final DateTime? initValue;
  final Function(DateTime) updateValue;
  final bool readonly;

  const FormFieldDateTimePicker(
      {required this.label,
      required this.initValue,
      required this.updateValue,
      this.readonly = false,
      Key? key})
      : super(key: key);

  @override
  _FormFieldDateTimePickerState createState() =>
      _FormFieldDateTimePickerState();
}

class _FormFieldDateTimePickerState extends State<FormFieldDateTimePicker> {
  late double _height;
  late double _width;

  late String _hour, _minute, _time;

  late bool _noValue;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  DateTime get selectedDateTime {
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        selectedTime.hour, selectedTime.minute);
  }

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
        widget.updateValue(selectedDateTime);
      });
    }
  }

  Future _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        widget.updateValue(selectedDateTime);
      });
    }
  }

  void _initDateTime(DateTime dt) {
    selectedDate = dt;
    selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);

    _dateController.text = DateFormat.yMd().format(dt);
    _timeController.text = formatDate(
            DateTime(2019, 08, 1, dt.hour, dt.minute), [hh, ':', nn, " ", am])
        .toString();
  }

  @override
  void initState() {
    _noValue = widget.initValue == null;
    if (!_noValue) {
      _initDateTime(widget.initValue!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(builder: (ctx) {
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      return InputDecorator(
          decoration: InputDecoration(
              constraints: const BoxConstraints(maxHeight: 70),
              labelText: widget.label,
              contentPadding: const EdgeInsets.only(top: 10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _noValue
                ? <Widget>[
                    TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).hintColor),
                                  borderRadius: BorderRadius.circular(16))),
                          // backgroundColor: MaterialStateProperty.all(Theme.of(context).toggleableActiveColor),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.only(left: 15, right: 15)),
                        ),
                        onPressed: () => setState(() {
                              _initDateTime(DateTime.now());
                              _noValue = false;
                            }),
                        child: Text("Add date",
                            style: Theme.of(context).textTheme.bodyText2!.merge(
                                TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline))))
                  ]
                : <Widget>[
                    InkWell(
                      onTap: () {
                        if (!widget.readonly) _selectDate(context);
                      },
                      child: Container(
                        width: _width / 4,
                        height: _height / 18,
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          enabled: false,
                          keyboardType: TextInputType.text,
                          controller: _dateController,
                          decoration: const InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              // labelText: 'Time',
                              contentPadding: EdgeInsets.only(top: 0.0)),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (!widget.readonly) _selectTime(context);
                      },
                      child: Container(
                        width: _width / 4,
                        height: _height / 18,
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          enabled: false,
                          keyboardType: TextInputType.text,
                          controller: _timeController,
                          decoration: const InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              // labelText: 'Time',
                              contentPadding: EdgeInsets.all(5)),
                        ),
                      ),
                    ),
                  ],
          ));
    });
  }
}
