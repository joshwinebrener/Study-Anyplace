import 'package:flutter/material.dart';
import 'package:study_anyplace/login_page.dart';
import 'package:study_anyplace/homepage.dart';
import 'package:study_anyplace/auth.dart' as auth;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study AnyPlace',
      theme: new ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        primaryColor: Color(0xFF831414),
        accentColor: Colors.amber[800],
        buttonColor: Colors.amber[800],
      ),
      /// Uses a futurebuilder.  If it can authenticate with stored credentials,
      /// then return the homepage, and if not, the login page.
      home: FutureBuilder(
        future: auth.authenticate(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done: 
              return (snapshot.data == true) ? HomePage() : LoginPage();
            break;
            default: return Scaffold();
            break;
          }
        },
      ),
    );
  }
}