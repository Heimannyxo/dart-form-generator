import 'package:flutter/material.dart';

import '../form_generator.dart';

class FormFieldDropdown extends StatefulWidget {
  final String label;
  final String? initiallySelected;
  final List<KeyValuePair> items;
  final bool allowNullValue;
  final FormFieldValidator<String>? validator;

  final void Function(String?) updateValue;

  const FormFieldDropdown(
      {required this.label,
      required this.initiallySelected,
      required this.items,
      required this.updateValue,
      this.allowNullValue = false,
      this.validator,
      Key? key})
      : super(key: key);

  @override
  FormFieldDropdownState createState() => FormFieldDropdownState();
}

class FormFieldDropdownState extends State<FormFieldDropdown> {
  String? _defaultValidator(String? v) => null;

  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected;
  }

  @override
  Widget build(BuildContext context) {
    var disabledColor = Theme.of(context).disabledColor;

    final InputDecoration effectiveDecoration = InputDecoration(labelText: widget.label)
        .applyDefaults(Theme.of(context).inputDecorationTheme);

    return FormField<String>(
      initialValue: _selected,
      validator: widget.validator ?? _defaultValidator,
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: effectiveDecoration.copyWith(errorText: state.errorText),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selected,
              isDense: true,
              onChanged: (String? newValue) {
                setState(() {
                  widget.updateValue.call(newValue);
                  _selected = newValue;
                  state.didChange(newValue);
                });
              },
              items: widget.allowNullValue
                  ? [_getNullItem(disabledColor), ..._getDropdownItems()]
                  : _getDropdownItems(),
            ),
          ),
        );
      },
    );
  }

  DropdownMenuItem<String> _getNullItem(Color disabledColor) {
    return DropdownMenuItem<String>(
      value: null,
      child: Text("-- no value --", style: TextStyle(color: disabledColor)),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    return widget.items.map((pair) {
      return DropdownMenuItem<String>(
        value: pair.key,
        child: Text(pair.value),
      );
    }).toList();
  }
}
