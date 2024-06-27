import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

RegExp _passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()-_+=])[A-Za-z\d!@#$%^&*()-_+=]{4,10}$');

String? _validateEmpty(String? value, bool optional) {
  if (optional || (value != null && value.isNotEmpty)) {
    return null;
  }
  return "Este campo es requerido";
}


String? _validatePassword(String? value,validateStrenght) {
  if (!validateStrenght) {
    return null;
  }

  var msg = "La contraseña debe tener 4 a 10 dígitos y tener mayúsculas, minúsculas y caracteres especiales";
  if (value != null && !value.isNotEmpty) {
    return msg;
  }

  if (value != null && !_passwordRegex.hasMatch(value)) {
    return msg;
  }

  return null;
}


class LabeledTextField extends StatelessWidget {
  const LabeledTextField({super.key, required this.labelText, this.controller, this.optional = true, this.onSaved, this.disabled = false, this.initialValue
  });

  final String labelText;
  final TextEditingController? controller;
  final bool optional;
  final Function(String?)? onSaved;
  final bool disabled;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => _validateEmpty(value,optional),
      onSaved: onSaved,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText 
      ),
      enabled: !disabled,
      initialValue: initialValue,
    );
  }
}


class PhoneNumberLabeledTextField extends StatelessWidget {
  const PhoneNumberLabeledTextField({super.key, required this.labelText, this.controller, this.optional = true, this.onSaved, this.disabled = false, this.initialValue});

  final String labelText;
  final TextEditingController? controller;
  final bool optional;
  final Function(String?)? onSaved;
  final bool disabled;
  final String? initialValue;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => _validateEmpty(value,optional),
      onSaved: onSaved,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly 
      ],
      decoration: InputDecoration(
        labelText: labelText 
      ),
      enabled: !disabled,
      initialValue: initialValue,
    );
  }
}


class CidLabeledTextField extends StatelessWidget {
  const CidLabeledTextField({super.key, required this.labelText, this.controller, this.optional = true, this.onSaved, this.disabled = false, this.onChanged, this.initialValue});

  final String labelText;
  final TextEditingController? controller;
  static final RegExp _regex = RegExp(r"^\d{10}$");
  final bool optional;
  final Function(String?)? onSaved;
  final bool disabled;
  final Function(String)? onChanged;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: (value) {
        var prevValidation = _validateEmpty(value, optional);

        if (prevValidation != null) {
          return prevValidation;
        }

        if (value == null || _regex.hasMatch(value)) {
          return null;
        }
        return "Cédula de formato incorrecto. Debe tener 10 dígitos"; 
      },
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly 
      ], 
      decoration: InputDecoration(
        labelText: labelText 
      ),
      onChanged: onChanged,
      enabled: !disabled,
      initialValue: initialValue,
    );
  }
}

class PasswordLabeledTextField extends StatelessWidget {
  const PasswordLabeledTextField({super.key, required this.labelText, this.controller, this.shouldBeEqualTo, this.optional = true, this.validateStrenght=true, this.onSaved, this.disabled = false, this.initialValue, this.onChanged });

  final String labelText;
  final TextEditingController? controller;
  final String? Function()? shouldBeEqualTo;
  final bool optional;
  final bool validateStrenght;
  final Function(String?)? onSaved;
  final bool disabled;
  final String? initialValue;
  final Function(String)? onChanged;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: (value) {
        var prevValidation = _validatePassword(value,validateStrenght) ?? _validateEmpty(value, optional);

        if (prevValidation != null) {
          return prevValidation;
        }

        if (shouldBeEqualTo == null || value == null) {
          return null;
        }

        var comparator = shouldBeEqualTo?.call();
        if (comparator == value) {
          return null;
        }

        return "Las contraseñas no coinciden";
      },
      obscureText: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText
      ),
      enabled: !disabled,
      onChanged: onChanged,
      initialValue: initialValue,
    );
  }
}


class EmailLabeledTextField extends StatelessWidget {
  const EmailLabeledTextField({super.key, required this.labelText, this.controller, this.optional = true, this.onSaved, this.disabled = false, this.initialValue});

  final String labelText;
  final TextEditingController? controller;
  final bool optional;
  final Function(String?)? onSaved;
  final bool disabled;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => _validateEmpty(value,optional),
      onSaved: onSaved,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText 
      ),
      enabled: !disabled,
      initialValue: initialValue,
    );
  }
}
