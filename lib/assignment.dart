import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:study_anyplace/auth.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

String _cookie;
bool firstRefresh = true;

class Assignment {
  final String title;
  final double points;
  Duration status;
  final DateTime dateDue;
  final String section;
  String timeFromNow;
  String key;
  int id;
  int gbScoreId;

  Assignment.fromJson(Map jsonMap)
    : title = jsonMap['title'],
      points = jsonMap['points'],
      dateDue = DateTime.parse(jsonMap['date_due']),
      id = jsonMap['id'],
      key = jsonMap['key'],
      gbScoreId = jsonMap['gb_score_id'],
      section = jsonMap['section']
  {
    status = dateDue.difference(DateTime.now());
    if (status.inHours > 48)
      timeFromNow = 'due in ${status.inDays.toString()} days';
    else if (status.inHours <= 48 && status.inHours > 0)
      timeFromNow = 'due in ${status.inHours.toString()} hours';
    else if (status.inHours <= 0 && status.inHours > -48)
      timeFromNow = 'due ${(-status.inHours).toString()} hours ago';
    else
      timeFromNow = 'due ${(-status.inDays).toString()} days ago';
  }
}

/// Retrieves a stream of assignments from the network the first time and
/// from the cache each time after
Future<Stream<Assignment>> getAssignments() async {
  final storage = new FlutterSecureStorage();
  // Return a demo json file for Apple
  if (await storage.read(key: 'username') == 'ttestfamily') return getAssignmentsFromFile();
  // Retrieve from cache on first load, to improve load speed
  if (firstRefresh) {
    firstRefresh = false;
    return getAssignmentsFromCache()
      .catchError((_) => getAssignmentsFromNetwork());
  }
  return getAssignmentsFromNetwork()
    .catchError((_) => getAssignmentsFromCache());
}

/// Retrieves a stream of assignments from the network, and gets files from
/// the local cache if it fails.
Future<Stream<Assignment>> getAssignmentsFromNetwork() async {
  await auth.authenticate();
  final storage = new FlutterSecureStorage();
  _cookie = await storage.read(key: 'cookie');
  // Upcoming Assignments
  const url = 'https://www.pottersschool.org/StudyPlace/cc/lms_due_item/family?&type=remaining&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22date_due%22%2C%22direction%22%3A%22ASC%22%7D%5D';
  
  // TODO: add support for all assignments
  //const allUrl = 'https://www.pottersschool.org/StudyPlace/cc/lms_due_item/family?_dc=1543528152406&type=All&page=1&start=0&limit=1000&sort=[{"property":"date_due","direction":"ASC"}]';
  
  FileInfo fileInfo = await DefaultCacheManager().downloadFile(
    url,
    authHeaders: {'Cookie': _cookie,}
  );

  return new Stream.fromFuture(fileInfo.file.readAsString()).transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonAssignment) => new Assignment.fromJson(jsonAssignment));
}

/// Retrieves a demo stream of assignments from a local json asset
Future<Stream<Assignment>> getAssignmentsFromFile() async {
  return new Stream.fromFuture(rootBundle.loadString('assets/assignments.json'))
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonAssignment) => new Assignment.fromJson(jsonAssignment));
}

/// Retrieves a stream of assignments from a local cache, and gets files
/// from the network if it fails.
Future<Stream<Assignment>> getAssignmentsFromCache() async {
  final url = 'https://www.pottersschool.org/StudyPlace/cc/lms_due_item/family?&type=remaining&page=1&start=0&limit=50&sort=%5B%7B%22property%22%3A%22date_due%22%2C%22direction%22%3A%22ASC%22%7D%5D';
  FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
  return new Stream.fromFuture(fileInfo.file.readAsString())
    .transform(json.decoder)
    .expand((jsonBody) => (jsonBody as Map)['rs'])
    .map((jsonAssignment) => new Assignment.fromJson(jsonAssignment));
}