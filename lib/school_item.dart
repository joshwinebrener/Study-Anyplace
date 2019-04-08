import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:study_anyplace/assignment.dart';
import 'package:study_anyplace/message.dart';
import 'package:study_anyplace/simple_html_view.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:study_anyplace/coin_button.dart';

class SchoolItem extends StatelessWidget {
  SchoolItem(this.icon, this.title, this.subtitle, this.date, this.metadata, this.data);
  
  final Widget icon;
  final String title;
  final String subtitle;
  final String date;
  final String metadata;
  final Widget data;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.2,
              color: Colors.grey,
            ),
          ),
        ),
        height: 100.0,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0
              ),
              child: this.icon,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: VerticalDivider(),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(),
                  Text(
                    this.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    this.date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return ItemSheet(this.title, '${this.subtitle}\n\n${this.metadata}', this.data);
          }
        );
      },
    );
  }
}

class AssignmentItem extends SchoolItem {
  AssignmentItem.fromAssignment(Assignment assignment) : super(
    CircleAvatar(
      radius: 24.0,
      backgroundColor: assignment.status.inSeconds > 0 ? Colors.green : Colors.red,
      child: Icon(
        Icons.edit,
        color: Colors.grey[850],
        size: 30.0,
      ),
    ),
    assignment.title,
    '${assignment.section}',
    DateFormat.yMd().add_jm().format(assignment.dateDue).toString(),
    '${assignment.points.toString()} points',
    FutureBuilder(
      future: fetchAssignmentBody(assignment),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) return
          SimpleHtmlView(data: snapshot.data);
        else return FittedBox(
          fit: BoxFit.none,
          child: Center(
            child: CircularProgressIndicator()
          )
        );
      },
    ),
  );
}

class MessageItem extends SchoolItem {
  MessageItem.fromMessage(Message message) : super(
    CoinButton(message: message),
    message.title, 
    message.author,
    DateFormat.yMd().format(DateTime.parse(message.date)).toString(),
    '${message.section}\n${message.type}',
    //Text(parse(simplifyHtml(message.html)).documentElement.text),
    Html(
      data: message.html,
      onLinkTap: (url) async {
        if (await canLaunch(url)) {
          await launch(
            url,
          );
        } else {
          throw 'Could not launch $url';
        }
      },
    ),
    //message.isRead ? Colors.green : Colors.red,
  );
}

class ItemSheet extends StatelessWidget {
  ItemSheet(this.title, this.subtitle, this.data);
  final String title;
  final String subtitle;
  final Widget data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: new ListView(
        children: <Widget> [
          Text(this.title,),
          Text(this.subtitle,),
          Divider(),
          data,
        ]
      ),
    );
  }
}

Future<String> fetchAssignmentBody(Assignment assignment) async {
  if (assignment.id == 0 && assignment.gbScoreId == 0) {
    return rootBundle.loadString('assets/demo.html');
  }
  String _json;
  var _url = 'https://www.pottersschool.org/cc/router';
  final storage = new FlutterSecureStorage();
  String _cookie = await storage.read(key: 'cookie');
  var client = http.Client();
  String requestBody = '{"action":"xpsDesktop","method":"action","data":["lmsGetDueInstance",['
    + '"${assignment.id}","${assignment.gbScoreId}"'
    + ']],"type":"rpc","tid":1}';

  await client.post(
    _url,
    body: requestBody,
    headers: {'Cookie': _cookie},
  ).then((response) {
    _json = response.body;
  });

  return json.decode(_json)[0]['result'];
}