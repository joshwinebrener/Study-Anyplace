import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_anyplace/auth.dart' as auth;
import 'dart:convert';
import 'package:http/http.dart' as http;

bool firstRefresh = true;
final _url = 'https://www.pottersschool.org/StudyPlace/cc/announcement/crud?&type=mine';

class Message {
  final String title;
  final String section;
  final String date;
  final String html;
  final String author;
  bool isRead;
  final String type;
  final String id;

  Message.fromJson(Map jsonMap)
    : title = jsonMap['title'],
      section = jsonMap['section'],
      date = jsonMap['date'],
      html = jsonMap['html'],
      author = jsonMap['author'],
      isRead = jsonMap['read'],
      type = jsonMap['type'],
      id = jsonMap['id'];

  void toggleRead() async {
    if (this.isRead) markUnread();
    else markRead();
    this.isRead = !this.isRead;
  }

  void markRead() async {
    await auth.authenticate();
    final storage = new FlutterSecureStorage();
    String _cookie = await storage.read(key: 'cookie');

    var client = http.Client();
    client.put(
      _url,
      headers: {
        'Cookie': _cookie,
        'Content-Type': 'application/json',
      },
      body: '{"id":"${this.id}","_action":"markRead"}',
    );
  }

    void markUnread() async {
    await auth.authenticate();
    final storage = new FlutterSecureStorage();
    String _cookie = await storage.read(key: 'cookie');

    var client = http.Client();
    client.put(
      _url,
      headers: {
        'Cookie': _cookie,
        'Content-Type': 'application/json',
      },
      body: '{"id":"${this.id}","_action":"markUnread"}',
    );
  }
}

/// Retrieves a stream of messages either from the network or local asset
Future<Stream<Message>> getMessages() async {
  final storage = new FlutterSecureStorage();
  if (await storage.read(key: 'username') == 'ttestfamily') return getMessagesFromFile();
  if (firstRefresh) {
    firstRefresh = false;
    return getMessagesFromCache()
      .catchError((_) => getMessagesFromNetwork());
  }
  return getMessagesFromNetwork()
    .catchError((_) => getMessagesFromCache());
}

/// Retrieves a stream of messages from the network
Future<Stream<Message>> getMessagesFromNetwork() async {
  await auth.authenticate();
  final storage = new FlutterSecureStorage();
  String _cookie = await storage.read(key: 'cookie');
  FileInfo fileInfo = await DefaultCacheManager().downloadFile(
    _url,
    authHeaders: {'Cookie': _cookie,}
  );
  return new Stream.fromFuture(fileInfo.file.readAsString()).transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonAssignment) => new Message.fromJson(jsonAssignment));
}

/// Retrieves a stream of messages from a local demo json asset
Future<Stream<Message>> getMessagesFromFile() async {
  return new Stream.fromFuture(rootBundle.loadString('assets/messages.json'))
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonMessage) => new Message.fromJson(jsonMessage));
}

/// Retrieves the messages from cache
Future<Stream<Message>> getMessagesFromCache() async {
  FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(_url);
  return new Stream.fromFuture(fileInfo.file.readAsString())
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonMessage) => new Message.fromJson(jsonMessage));
}