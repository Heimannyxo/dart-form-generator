import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormFieldNumber<TNum extends num> extends StatefulWidget {
  final String label;
  final TNum initValue;
  final void Function(dynamic) updateValue;
  final bool readonly;
  final TNum? step;
  final TNum? min;
  final TNum? max;
  final FormFieldValidator<TNum>? validator;

  const FormFieldNumber(
      {required this.label,
      required this.initValue,
      required this.updateValue,
      this.readonly = false,
      this.min,
      this.max,
      this.step,
      this.validator,
      Key? key})
      : super(key: key);

  @override
  _FormFieldNumberState createState() => _FormFieldNumberState();
}

class _FormFieldNumberState<TNum extends num>
    extends State<FormFieldNumber<TNum>> {
  late TNum _value;
  late TextEditingController _ctrl;
  late TNum _step;
  late bool _isDecimal;
  late RegExp _allowSymbols;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
    _ctrl = TextEditingController.fromValue(
        TextEditingValue(text: _value.toString()));
    _step = widget.step ?? (1 as TNum);
    _isDecimal = TNum == double;
    _allowSymbols = RegExp("[0-9${_isDecimal ? '.' : ''}-]");
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    return FormField<TNum>(
        validator: widget.validator,
        initialValue: _value,
        builder: (buildContext) {
          return GestureDetector(
              onTap: () => focusNode.requestFocus(),
              child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.label,
                    // contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  ),
                  child: _buildInput(context, focusNode)
                  // _buildInput(context)
                  ));
        });
  }

  Widget _buildInput(BuildContext context, FocusNode focusNode) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputStyle =
        (Theme.of(context).textTheme.subtitle1 ?? const TextStyle());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBtn(increase: false, color: colorScheme.secondary),
        Expanded(
          child: EditableText(
              controller: _ctrl,
              focusNode: focusNode,
              style: inputStyle,
              textInputAction: TextInputAction.none,
              cursorColor: colorScheme.primary,
              backgroundCursorColor: colorScheme.onBackground,
              textAlign: TextAlign.center,
              readOnly: widget.readonly,
              keyboardType: TextInputType.numberWithOptions(
                  signed: true, decimal: _isDecimal),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(_allowSymbols)
              ],
              onChanged: (v) => setState(() => _updateValue(v))),
        ),
        _buildIconBtn(increase: true, color: colorScheme.secondary)
      ],
    );
  }

  Widget _buildIconBtn({required bool increase, required Color color}) {
    final left = increase ? 14.0 : 4.0;
    final right = increase ? 4.0 : 14.0;
    final icon = increase ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
    final delta = increase ? _step : -_step;
    void action() => setState(() {
      _value = (_value + delta) as TNum;
      _updateCtrl();
    });

    return InkWell(
      onTap: action,
      onLongPress: action,
      child: Ink(
        padding: EdgeInsets.only(left: left, right: right),
        child: Icon(icon, color: color),
      ),
    );
  }

  void _updateCtrl() {
    _ctrl.text = _value.toString();
    widget.updateValue(_value);
  }

  void _updateValue(String s) {
    if (_value is double) _value = (double.tryParse(s) as TNum?) ?? _value;
    if (_value is int) _value = (int.tryParse(s) as TNum?) ?? _value;
    widget.updateValue(_value);
  }
}
