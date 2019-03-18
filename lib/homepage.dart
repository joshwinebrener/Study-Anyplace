import 'package:flutter/material.dart';
import 'package:study_anyplace/assignments_page.dart';
import 'package:study_anyplace/messages_page.dart';
import 'auth.dart' as auth;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AssignmentsPage _assignmentsPage = AssignmentsPage(key: GlobalKey());
    final MessagesPage _messagesPage = MessagesPage(key: UniqueKey());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              tooltip: 'Logout',
              onPressed: () => auth.logout(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Assignments'),
              Tab(text: 'Messages'),
            ],
          ),
          title: Text('Study Anyplace'),
        ),
        body: TabBarView(
          children: [
            _assignmentsPage,
            _messagesPage,
          ],
        ),
      ),
    );
  }
}