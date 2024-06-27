import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_final_movil/components/labeled_text_field.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final _data = LoginDTO();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var preferences = context.watch<UserModel>();

    return  Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de Sesión")
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.account_circle_rounded, size: 90.0,),
              EmailLabeledTextField(
                labelText: "Correo electrónico", 
                optional: false, 
                onSaved: (value) { _data.correo = value!; },
              ),
              PasswordLabeledTextField(
                labelText: "Contraseña",
                optional: false,
                validateStrenght: false,
                disabled: false,
                onSaved: (value) { _data.clave = value!; },
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  if (!_key.currentState!.validate()) {
                    return;
                  }

                  _key.currentState!.save();
                  var logged = await preferences.login(_data); 
                  var snack = SnackBar(content: Text(logged? "Ingreso Exitoso" : "Error de Inicio de sesión"));

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(snack);

                  if (logged) {
                    context.pop();
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary
                ),
                child: const Text("Iniciar Sesión"),
              ),
              TextButton(
                onPressed: () { context.push('/register'); },
                child: const Text("Registrar Usuario")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
