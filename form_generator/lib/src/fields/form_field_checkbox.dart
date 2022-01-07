import 'package:flutter/material.dart';

class FormFieldCheckbox extends StatefulWidget {
  final String label;
  final bool value;
  final void Function(bool) updateValue;
  final bool readonly;

  const FormFieldCheckbox(
      {required this.label,
      required this.value,
      required this.updateValue,
      this.readonly = false,
      Key? key})
      : super(key: key);

  @override
  FormFieldCheckboxState createState() => FormFieldCheckboxState();
}

class FormFieldCheckboxState extends State<FormFieldCheckbox> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(builder: (FormFieldState<bool> state) {
      return Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Theme.of(context).disabledColor))),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: InputDecorator(
                      isEmpty: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          constraints: const BoxConstraints(maxHeight: 50),
                          labelText: widget.label),
                    )),
                Expanded(
                    flex: 5,
                    child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        activeColor: !widget.readonly || _value ? Theme.of(context).colorScheme.secondary : Theme.of(context).disabledColor,
                        value: widget.readonly && !_value ? null : _value,
                        tristate: widget.readonly,
                        onChanged: (newValue) {
                          if (widget.readonly) return;
                          setState(() {
                            _value = newValue ?? false;
                            widget.updateValue(newValue ?? false);
                          });
                        }))
              ]));
    });
  }
}
