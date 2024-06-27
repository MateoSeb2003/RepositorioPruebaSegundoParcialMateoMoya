import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_movil/model/user.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final actions = userModel.actions;
    final userName = userModel.userNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Acciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Usuario: $userName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return ListTile(
                    title: Text(action.action),
                    subtitle: Text(action.timestamp.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
