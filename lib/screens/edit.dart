import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final_movil/components/labeled_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key, this.idUsuario});

  final String? idUsuario;

  @override
  State<StatefulWidget> createState() {
    return _EditUserState();
  }
}

class _EditUserState extends State<EditUser> {
  final _data = User();
  final _key = GlobalKey<FormState>();

  Future<User?>? _future;

  @override
  Widget build(BuildContext context) {
    var users = context.watch<UserModel>();
    _future ??= Future(() {
      var model = Provider.of<UserModel>(context, listen: false);
      if (model.userCid == null) {
        return Future.value(null);
      }
      return model.getUserWithClient(model.userCid!);
    });

    return FutureBuilder<User?>(
        future: _future,
        builder: (builderCtx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text("Registro de Usuario")),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Registro de Usuario")),
              body: const Center(
                child: Text("Error al cargar los datos del usuario"),
              ),
            );
          }

          _data.clave = snapshot.data?.clave ?? "";
          return Scaffold(
            appBar: AppBar(title: const Text("Registro de Usuario")),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _key,
                child: ListView(
                  children: [
                    const Icon(Icons.account_circle_rounded, size: 100),
                    LabeledTextField(
                      labelText: "Cédula",
                      optional: false,
                      disabled: true,
                      onSaved: (value) {
                        _data.cedulaCliente = value!;
                      },
                      initialValue: snapshot.data?.cedulaCliente ?? "",
                    ),
                    LabeledTextField(
                      labelText: "Nombres Completos",
                      optional: false,
                      onSaved: (value) {
                        _data.nombreCompleto = value!;
                      },
                      initialValue: snapshot.data?.nombreCompleto ?? "",
                    ),
                    LabeledTextField(
                      labelText: "Correo Electrónico",
                      optional: false,
                      onSaved: (value) {
                        _data.correo = value!;
                      },
                      initialValue: snapshot.data?.correo ?? "",
                    ),
                    LabeledTextField(
                      labelText: "Dirección",
                      optional: false,
                      onSaved: (value) {
                        _data.direccion = value!;
                      },
                      initialValue: snapshot.data?.direccion ?? "",
                    ),
                    PasswordLabeledTextField(
                      labelText: "Contraseña",
                      optional: false,
                      onSaved: (value) {
                        if (value == null || value.isEmpty) {
                          _data.clave = snapshot.data?.clave;
                        } else {
                          _data.clave = value;
                        }
                      },
                      onChanged: (value) {
                        _data.clave = value;
                      },
                      initialValue: snapshot.data?.clave ?? "",
                    ),
                    PasswordLabeledTextField(
                      labelText: "Confirmar Contraseña",
                      optional: false,
                      shouldBeEqualTo: () => _data.clave,
                      initialValue: snapshot.data?.clave ?? "",
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_key.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, corrija los errores en el formulario.'),
                              ),
                            );
                            return;
                          }
                          _data.idUsuario = snapshot.data?.idUsuario ?? 0;
                          _key.currentState!.save();
                          bool success = await users.putUser(_data);
                          var snack = SnackBar(
                              content: Text(success
                                  ? 'Usuario registrado'
                                  : 'Error al registrar el usuario. Consulte con soporte técnico'));
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                          if (success) {
                            context.pop();
                          }
                        },
                        child: const Text("Actualizar Usuario"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
