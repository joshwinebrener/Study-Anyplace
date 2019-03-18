import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_anyplace/auth.dart' as auth;
import 'dart:convert';

bool firstRefresh = true;

class Message {
  final String title;
  final String section;
  final String date;
  final String html;
  final String author;
  final bool isRead;
  final String type;

  Message.fromJson(Map jsonMap)
    : title = jsonMap['title'],
      section = jsonMap['section'],
      date = jsonMap['date'],
      html = jsonMap['html'],
      author = jsonMap['author'],
      isRead = jsonMap['read'],
      type = jsonMap['type'];
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
  final url = 'https://www.pottersschool.org/StudyPlace/cc/announcement/crud?_dc=1536679750592&type=mine&page=1&start=0&limit=1000';
  FileInfo fileInfo = await DefaultCacheManager().downloadFile(
    url,
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
  final url = 'https://www.pottersschool.org/StudyPlace/cc/announcement/crud?_dc=1536679750592&type=mine&page=1&start=0&limit=1000';
  FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
  return new Stream.fromFuture(fileInfo.file.readAsString())
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonMessage) => new Message.fromJson(jsonMessage));
}