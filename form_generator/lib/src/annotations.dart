import 'package:form_generator/form_generator.dart';
import 'package:reflectable/reflectable.dart';

class FormInclude {
  final List<FormIncludeType> types;
  final String? fieldId;
  final String? fieldName;
  final bool isReadonly;
  final bool isRequired;
  final String? Function(dynamic)? validator;
  final List<KeyValuePair> Function()? _dropdownData;

  const FormInclude(
      {required this.types,
      this.fieldId,
      this.fieldName,
      this.isReadonly = false,
      this.isRequired = false,
      this.validator,
      getDropdownData})
      : _dropdownData = getDropdownData;

  List<KeyValuePair>? get dropdownData {
    return _dropdownData != null ? _dropdownData!.call() : null;
  }
}

enum FormIncludeType { all, create, edit, view }

const formSerializable = FormSerializable();

class FormSerializable extends Reflectable {
  const FormSerializable()
      : super(
            invokingCapability,
            typingCapability,
            reflectedTypeCapability,
            typeCapability,
            newInstanceCapability,
            typeAnnotationQuantifyCapability,
            typeRelationsCapability,
            superclassQuantifyCapability,
            instanceInvokeCapability);
}
