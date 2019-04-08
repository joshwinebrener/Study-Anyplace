import 'package:flutter/material.dart';
import 'package:study_anyplace/school_item.dart';
import 'assignment.dart';

class AssignmentsPage extends StatefulWidget {
    final String title;

    AssignmentsPage({Key key, this.title}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<Assignment> assignmentList = List<Assignment>();

  // Retrieves a list of assignments from a stream
  _getAssignments() async {
    assignmentList.clear();

    Stream<Assignment> stream = await getAssignments();

    stream.listen((assignment) {
      assignmentList.add(assignment);
    }).onDone(() => setState(() => assignmentList = assignmentList));
  }

  @override
  initState() {
    super.initState();

    _getAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _getAssignments(),
        child: new ListView(
          children: assignmentList.map((assignment) => new AssignmentItem.fromAssignment(assignment)).toList(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}