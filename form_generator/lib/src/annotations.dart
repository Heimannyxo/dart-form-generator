import 'package:reflectable/reflectable.dart';

class FormInclude {
  final List<FormIncludeType> types;
  final String? fieldId;
  final String? fieldName;
  final bool isReadonly;
  final bool isRequired;
  final String? Function(dynamic)? validator;

  const FormInclude(
      {required this.types,
      this.fieldId,
      this.fieldName,
      this.isReadonly = false,
      this.isRequired = false,
      this.validator});
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
