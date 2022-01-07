// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:form_generator/src/annotations.dart';
import 'package:form_generator/src/fields/form_field_text.dart';
import 'package:form_generator/src/validation.dart' as validate;
import 'package:reflectable/mirrors.dart';

import 'fields/form_field_checkbox.dart';
import 'fields/form_field_datetime_picker.dart';
import 'fields/form_field_dropdown.dart';
import 'fields/form_field_number.dart';
import 'fields/form_field_readonly.dart';

class FormGenerator<TItem> {
  final _typeMirror = formSerializable.reflectType(TItem) as ClassMirror;

  late final GlobalKey<FormState> _formKey;
  late final _FormController _formCtrl;

  late FormType _formType;
  late Function(dynamic)? _onSubmit;
  late TItem? _initData;
  late InstanceMirror? _initDataMirror;
  late Map<String, List<KeyValuePair>> _dropdownItems;

  FormGenerator() {
    _formCtrl = _FormController();
  }

  Widget buildForm(FormType formType,
      {Function(dynamic)? onSubmit,
      TItem? initData,
      Map<String, List<KeyValuePair>>? dropdownItems}) {
    _formKey = GlobalKey<FormState>(
        debugLabel: "${formType.name} form for ${_typeMirror.simpleName}");
    _formType = formType;
    _onSubmit = onSubmit;
    _initData = initData;
    _initDataMirror =
        initData != null ? formSerializable.reflect(initData) : null;
    _dropdownItems = dropdownItems ?? HashMap();

    return Form(
        key: _formKey,
        child: Builder(builder: (ctx) => _buildFormContents(ctx)));
  }

  Widget _buildFormContents(BuildContext ctx) {
    final declarations = _typeMirror.declarations;
    final typeFields = declarations.entries
        .where((entry) => entry.value is VariableMirror)
        .where((entry) => entry.value.metadata
            .whereType<FormInclude>()
            .any((el) => el.types.any((type) => _formType.includes(type))));

    return Column(
      children: [
        ...typeFields
            .map((entry) =>
                _buildField(entry.key, entry.value as VariableMirror))
            .toList(),
        _formType == FormType.readonly
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(ctx).colorScheme.secondaryVariant,
                        fixedSize: const Size(250, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        textStyle: const TextStyle(fontSize: 25)),
                    onPressed: () => _submit(),
                    child: Text((_formType.btnLabel)))),
        Center(child: Text("${_formKey.hashCode}"))
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Object inst = _getInstanceToSubmit();
      var instMirror = formSerializable.reflect(inst);
      _formCtrl._valueHints.entries
          .where((entry) => entry.value.get() != null)
          .forEach((e) => instMirror.invokeSetter(e.key, e.value.get()));

      _onSubmit!.call(inst);
    }
  }

  Object _getInstanceToSubmit() {
    if (_initData != null) {
      return _initData!;
    }
    MethodMirror defaultConstructor = _typeMirror.declarations.values
        .where((declare) => declare is MethodMirror && declare.isConstructor)
        .map((e) => e as MethodMirror)
        .firstWhere((ctor) => ctor.constructorName.isEmpty);
    Map<Symbol, dynamic> namedParams = Map.fromEntries(defaultConstructor
        .parameters
        .where((param) => param.isNamed)
        .map((param) => MapEntry<Symbol, dynamic>(Symbol(param.simpleName),
            _formCtrl.getValueHint(param.simpleName)?.get()))
        .where((namedParam) => namedParam.value != null));
    var inst = _typeMirror.newInstance("", [], namedParams);
    return inst;
  }

  Widget _buildField(String fieldKey, VariableMirror typeField) {
    var type = typeField.type;
    var formInclude = _getFormInclude(typeField);
    var identifier = formInclude.fieldId ?? fieldKey;
    var label = formInclude.fieldName ?? fieldKey;
    var isRequired = formInclude.isRequired;
    var isReadonly = formInclude.isReadonly;
    var validator = formInclude.validator;
    var initData = _getInitData(fieldKey, typeField);
    dynamic getHint(identifier, ifAbsent) =>
        _formCtrl.getValueHintIfAbsent(identifier, ifAbsent);
    var isDropdown = _dropdownItems[identifier] != null;

    if (_formType == FormType.readonly) {
      var readData = isDropdown
          ? _dropdownItems[identifier]!.firstWhere(
              (pair) => pair.key == identifier,
              orElse: () => const KeyValuePair("nodata", ""))
          : initData;
      return FormFieldReadonly(label: label, value: readData, typeMirror: type);
    } else if (isDropdown) {
      final items = _dropdownItems[identifier]!;
      hintIfAbsent() =>
          _formCtrl.addValueHintFromValue<String?>(identifier, initData);
      var hint = getHint(identifier, hintIfAbsent);
      return FormFieldDropdown(
          label: label,
          initiallySelected: hint.get(),
          items: items,
          updateValue: (newVal) => hint.set(newVal),
          validator: validator ??
              (isRequired
                  ? (val) => validate.notEmpty(val, label)
                  : (val) => null));
    } else if (_isAssignableFrom(type, String)) {
      hintIfAbsent() =>
          _formCtrl.addValueHintFromValue<String?>(identifier, initData);
      var hint = getHint(identifier, hintIfAbsent);
      return FormFieldText(
          label: label,
          initValue: hint.get(),
          updateValue: (newVal) => hint.set(newVal),
          readonly: isReadonly,
          required: isRequired);
    } else if (_isAssignableFrom(type, int)) {
      hintIfAbsent() => _formCtrl.addValueHintFromValue<int>(
          identifier, (initData as int?) ?? 0);
      var hint = getHint(identifier, hintIfAbsent);
      return FormFieldNumber<int>(
          label: label,
          initValue: hint.get()!,
          updateValue: (newVal) => hint.set(newVal));
    } else if (_isAssignableFrom(type, bool)) {
      hintIfAbsent() => _formCtrl.addValueHintFromValue(
          identifier, (initData as bool?) ?? false);
      var hint = getHint(identifier, hintIfAbsent);
      return FormFieldCheckbox(
          label: label,
          value: hint.get()!,
          updateValue: (newVal) => hint.set(newVal),
          readonly: isReadonly);
    } else if (_isAssignableFrom(type, DateTime)) {
      hintIfAbsent() =>
          _formCtrl.addValueHintFromValue(identifier, initData as DateTime?);
      var hint = getHint(identifier, hintIfAbsent);
      return FormFieldDateTimePicker(
          label: label,
          initValue: hint.get(),
          updateValue: (newVal) => hint.set(newVal),
          readonly: isReadonly);
    }
    return Text("Error creating field for $fieldKey");
  }

  dynamic _getInitData(String fieldKey, VariableMirror typeField) {
    if (_initDataMirror == null) return null;
    try {
      return _initDataMirror!.invokeGetter(fieldKey);
    } on Error catch (e) {
      print(e.stackTrace);
      return null;
    }
  }

  FormInclude _getFormInclude(VariableMirror fieldMirror) {
    return fieldMirror.metadata.whereType<FormInclude>().first;
  }

  bool _isAssignableFrom(TypeMirror tm1, Type t2) {
    final tm2 = formSerializable.reflectType(t2);
    try {
      return tm1.isAssignableTo(tm2);
    } on Error {
      return tm1.reflectedType == t2;
    }
  }

  bool _isOneOf(TypeMirror tm, Iterable<Type> types) {
    return types.any((type) => _isAssignableFrom(tm, type));
  }
}

enum FormType { create, edit, readonly }

extension _FromTypeExt on FormType {
  bool includes(FormIncludeType includeType) {
    if (includeType == FormIncludeType.all) return true;
    switch (this) {
      case FormType.create:
        return includeType == FormIncludeType.create;
      case FormType.edit:
        return includeType == FormIncludeType.edit;
      case FormType.readonly:
        return includeType == FormIncludeType.view;
      default:
        return false;
    }
  }

  String get btnLabel {
    if (this == FormType.create) return "Create";
    if (this == FormType.edit) return "Edit";
    return "Don't show button";
  }
}

@formSerializable
class KeyValuePair {
  final String key;
  final String value;

  const KeyValuePair(this.key, this.value);
}

class _FormController {
  final Map<String, _ValueHint<dynamic>> _valueHints = {};
  final Map<String, Type> _hintTypes = {};

  _ValueHint<T> getValueHintIfAbsent<T>(
      String key, _ValueHint<T> Function() ifAbsent) {
    var stored = getValueHint<T>(key);
    return stored ?? ifAbsent.call();
  }

  _ValueHint<T>? getValueHint<T>(String key) {
    if (_valueHints.containsKey(key)) {
      var hint = _valueHints[key];
      var type = _hintTypes[key];
      if (type == T || T == dynamic) {
        return hint as _ValueHint<T>;
      }
    }
    return null;
  }

  _ValueHint<T> addValueHint<T>(
      String key, T Function() getter, Function(T?) setter) {
    var hint = _ValueHint(key, getter, setter);
    _valueHints[key] = hint;
    _hintTypes[key] = T;
    return hint;
  }

  _ValueHint<T> addValueHintFromValue<T>(String key, T initValue) {
    var hint = _ValueHint.fromValue(key, initValue);
    _valueHints[key] = hint;
    _hintTypes[key] = T;
    return hint;
  }
}

class _ValueHint<T> {
  late final String key;
  T? _value;

  late final T? Function() _getter;
  late final void Function(T?) _setter;

  _ValueHint(this.key, this._getter, this._setter);

  _ValueHint.fromValue(this.key, T? initValue) {
    _value = initValue;
    _getter = () => _value;
    _setter = (val) => _value = val;
  }

  T? get() => _getter.call();

  void set(T? val) => _setter.call(val);
}
