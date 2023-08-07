import 'package:flutter/material.dart';
import 'package:mobile/components/accepted_jobs.dart';
import 'package:mobile/components/created_jobs.dart';
import 'package:mobile/components/requests.dart';
import 'package:mobile/components/job_history.dart';
class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              'My Jobs-Requests',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              constraints: BoxConstraints.expand(height: 50),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                  TabBar(
                    labelColor: Color.fromRGBO(233, 116, 80, 1),
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      color: Colors.white,
                    ),
                    tabs: const <Widget>[
                      Tab(
                        text: 'Accepted',
                      ),
                      Tab(text: 'Created'),
                      Tab(text: 'Requests'),
                      Tab(text: 'History'),
                    ],
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  AcceptedJobsPage(),
                  CreatedJobsPage(),
                  RequestsPage(),
                  JobHistoryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
