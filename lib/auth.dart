import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

final String authFailMsg = '{"success":false,"errors":{"reason":"Login Failed: Please check your username and password and try again."}}';

Future<bool> authenticate({String username, String password}) async {
  
  bool _successful = false;
  // Use stored username/password if not used as parameters
  final storage = new FlutterSecureStorage();
  if (username == null) username = await storage.read(key: 'username');
  else await storage.write(key: 'username', value: username);
  if (password == null) password = await storage.read(key: 'password');
  else await storage.write(key: 'password', value: password);

  String cookie;
  var authUrl = 'https://www.pottersschool.org/j_spring_security_check';
  var client = http.Client();

  await client.post(
    authUrl,
    body: {
      'j_username': username,
      'j_password': password,
      'j_back' : '/student'
    }
  ).then((response) {
    cookie = response.headers['set-cookie'];
    storage.write(key: 'cookie', value: cookie);
    if (response.body == authFailMsg) _successful = false;
    else _successful = true;
  }).catchError((_) {
    _successful = false;
    return Future.value(true);
  });
  return new Future<bool>(() => _successful);
}

void logout(BuildContext context) async {
  final storage = new FlutterSecureStorage();

  storage.deleteAll();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    (_) => false,
  );
}