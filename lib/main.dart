import 'package:ecommerce_application/Signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homescreen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyA4MkV9EJ8Jpz6oQb8TJqigfDW4nOvTDoY",
          authDomain: "give4good-90ed5.firebaseapp.com",
          databaseURL: "https://give4good-90ed5-default-rtdb.firebaseio.com",
          projectId: "give4good-90ed5",
          storageBucket: "give4good-90ed5.appspot.com",
          messagingSenderId: "742348535375",
          appId: "1:742348535375:web:d04e370c1e25b779511c3a",
          measurementId: "G-PS4Y9CZY0T"
      )
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool login = prefs.getBool("Login") ?? false;
  String? token = prefs.getString("token");
  runApp(MyApp(login: login, token: token));
}

class MyApp extends StatelessWidget {
  final bool login;
  final String? token;

  MyApp({required this.login, required this.token});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: login && token != null ? Homescreen(token: token!) : Signin(),
    );
  }
}
