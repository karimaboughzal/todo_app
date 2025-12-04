import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/todo_list_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestionnaire de Tâches',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Vérifier si l'utilisateur est connecté
          if (snapshot.hasData && snapshot.data == true) {
            return const TodoListPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}