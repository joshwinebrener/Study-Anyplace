import 'package:flutter/material.dart';
import 'package:study_anyplace/school_item.dart';
import 'message.dart';

class MessagesPage extends StatefulWidget {
    final String title;

    MessagesPage({Key key, this.title}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();

  var messageList = <Message>[];

  // Retrieves a list of messages
  _getMessages() async {
    messageList.clear();

    Stream<Message> stream = await getMessages();
    stream.listen((message) => messageList.add(message))
    .onDone(() {
      // remove the news and announcements message until I know how to deal with it
      if (messageList[0].title == "News and Announcements") messageList.removeAt(0);
      setState(() => messageList = messageList);
    });
  }

  @override
  initState() {
    super.initState();

    _getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _getMessages(),
        child: new ListView(
          children: messageList.map((message) => new MessageItem.fromMessage(message)).toList(),
        ),
      ),
    );
  }

  @override
  // prevent the messages page widget from being recycled
  bool get wantKeepAlive => true;
}