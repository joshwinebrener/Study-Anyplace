import 'package:flutter/material.dart';
import 'package:study_anyplace/auth.dart' as auth;
import 'package:study_anyplace/homepage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loginFailed = false;

  @override
  void dispose() {
    // Clean up the controllers when the Widget is disposed
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("StudyAnyplace Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Username field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'username',
                ),
              ),
              // Password field
              TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'password',
                ),
              ),
              // Login button and transparent error message
              Row(
                children: <Widget>[
                  Expanded(
                    child: Opacity(
                      opacity: _loginFailed ? 1.0 : 0,
                      child: Text(
                        'Login Failed',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('login'),
                    onPressed: () async {
                      if (await auth.authenticate(
                        username: usernameController.text,
                        password: passwordController.text,
                      )) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage()),
                        );
                      } else {
                        setState(() {
                          _loginFailed = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}