import 'package:flutter/material.dart';
import '../validation.dart' as validate;

class FormFieldText extends StatefulWidget {
  final String label;
  final String? initValue;
  final void Function(dynamic) updateValue;
  final bool readonly;
  final bool required;
  final FormFieldValidator<String>? validator;

  const FormFieldText(
      {required this.label,
      required this.initValue,
      required this.updateValue,
      this.readonly = false,
      this.required = false,
      this.validator,
      Key? key})
      : super(key: key);

  @override
  _FormFieldTextState createState() => _FormFieldTextState();
}

class _FormFieldTextState extends State<FormFieldText> {
  late String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      initialValue: widget.initValue,
      readOnly: widget.readonly,
      validator: widget.validator ??
          (widget.required
              ? (v) => validate.notEmpty(v, widget.label)
              : null),
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) => setState(() {
        _value = v;
        widget.updateValue(_value);
      }),
    );
  }
}
