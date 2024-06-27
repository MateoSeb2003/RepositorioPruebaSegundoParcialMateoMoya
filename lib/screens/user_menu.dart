import 'package:proyecto_final_movil/model/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Menú de Usuario'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                TextButton(
                  child: const Text("Listar ordenes"), 
                  onPressed: () {
                    context.push('/history');
                  },
                ),
                TextButton(
                  child: const Text("Editar Información"), 
                  onPressed: () {
                    var user = Provider.of<UserModel>(context, listen: false);
                    context.push('/edit/${user.userId}');
                  },
                ),
                TextButton(
                  child: const Text("Cerrar Sesión"), 
                  onPressed: () {
                    var user = Provider.of<UserModel>(context, listen: false);
                    user.clearAll();
                    var snack = const SnackBar(
                      content: Text("Sesión de usuario cerrada")
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snack);
                    context.go('/');
                  },
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
