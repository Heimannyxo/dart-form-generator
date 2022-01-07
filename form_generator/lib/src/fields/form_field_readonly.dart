import 'package:flutter/material.dart';
import 'package:form_generator/src/form_generator.dart';
import 'package:reflectable/mirrors.dart';
import 'package:intl/intl.dart';

import '../annotations.dart';

class FormFieldReadonly extends StatelessWidget {
  final String label;
  final dynamic value;
  final TypeMirror typeMirror;

  const FormFieldReadonly(
      {required this.label,
      required this.value,
      required this.typeMirror,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            Text(
              " $label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _valueWidget(context)
          ],
        ));
  }

  Widget _valueWidget(context) {
    final theme = Theme.of(context);

    if (value == null) {
      return Text("- not set -", style: TextStyle(color: theme.disabledColor));
    } else if (value is KeyValuePair) {
      return Text((value as KeyValuePair).value);
    } else if (_isOneOf(typeMirror, [String, int])) {
      return Text(value.toString());
    } else if (_isAssignableFrom(typeMirror, DateTime)) {
      return Text(DateFormat.yMd().add_Hms().format(value));
    } else if (_isAssignableFrom(typeMirror, bool)) {
      return Icon(
          value == true ? Icons.check_box : Icons.indeterminate_check_box,
          color: value == true
              ? theme.colorScheme.secondary
              : theme.disabledColor);
    }
    throw Exception(
        "Unsupported value $value of type ${typeMirror.simpleName}");
  }

  bool _isAssignableFrom(TypeMirror tm1, Type t2) {
    final tm2 = formSerializable.reflectType(t2);
    try {
      return tm1.isAssignableTo(tm2);
    } on Error {
      return tm1.reflectedType == t2;
    }
  }

  bool _isOneOf(TypeMirror tm, List<Type> types) {
    return types.any((type) => _isAssignableFrom(tm, type));
  }
}
