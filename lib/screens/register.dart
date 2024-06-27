import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final_movil/components/labeled_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _data = User();
  final _key = GlobalKey<FormState>();
  bool disabled = true;
  bool isLoading = false;

  /// Controladores
  final nameFieldController = TextEditingController();
  final mailFieldController = TextEditingController();
  final addressFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var users = context.watch<UserModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: ListView(
            children: [
              const Icon(Icons.account_circle_rounded, size: 100),
              CidLabeledTextField(
                labelText: "Cédula",
                optional: false,
                onSaved: (value) {
                  _data.cedulaCliente = value!;
                },
                onChanged: (value) {
                  if (value.length == 10) {
                    users.getUserWithClient(value).then((user) {
                      setState(() {
                        disabled = false;
                      });
                      if (user == null) {
                        return;
                      }
                      setState(() {
                        _data.nombreCompleto = user.nombreCompleto;
                        nameFieldController.text = user.nombreCompleto!;
                        _data.correo = user.correo;
                        mailFieldController.text = user.correo!;
                        _data.direccion = user.direccion;
                        addressFieldController.text = user.direccion!;
                      });
                    });
                  }
                },
              ),
              LabeledTextField(
                labelText: "Nombres Completos",
                controller: nameFieldController,
                optional: false,
                onSaved: (value) {
                  _data.nombreCompleto = value!;
                },
                disabled: disabled,
              ),
              LabeledTextField(
                labelText: "Correo Electrónico",
                controller: mailFieldController,
                optional: false,
                onSaved: (value) {
                  _data.correo = value!;
                },
                disabled: disabled,
              ),
              LabeledTextField(
                labelText: "Dirección",
                controller: addressFieldController,
                optional: false,
                onSaved: (value) {
                  _data.direccion = value!;
                },
                disabled: disabled,
              ),
              PasswordLabeledTextField(
                labelText: "Contraseña",
                optional: false,
                onSaved: (value) {
                  _data.clave = value!;
                },
                onChanged: (value) {
                  _data.clave = value;
                },
                disabled: disabled,
              ),
              PasswordLabeledTextField(
                labelText: "Confirmar Contraseña",
                optional: false,
                disabled: disabled,
                shouldBeEqualTo: () => _data.clave,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  onPressed: isLoading || disabled ? null : () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (!_key.currentState!.validate()) {
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    _key.currentState!.save();
                    await users.postUser(_data).then((s) {
                      var snack = SnackBar(
                          content: Text(s
                              ? 'Usuario registrado'
                              : 'Error al registrar el usuario. Consulte con soporte técnico'));

                      ScaffoldMessenger.of(context).showSnackBar(snack);
                      if (s) {
                        setState(() {
                          isLoading = false;
                        });
                        context.pop();
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    });
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Registrar Usuario"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
