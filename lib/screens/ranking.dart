import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile/entities/job.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/entities/user_list.dart';
import 'package:mobile/screens/profile.dart';

import '../variables/logged_in_user.dart';

class UserRankingScreen extends StatefulWidget {
  @override
  _UserRankingScreenState createState() => _UserRankingScreenState();
}

class _UserRankingScreenState extends State<UserRankingScreen> {
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    fetchUserList();
  }

  Future<void> fetchUserList() async {
    var userinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/GetAllUser';
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      var dio = Dio();
      var userInfoResponse =
          await dio.get(userinfoendpointUrl, options: options);

      setState(() {
        List<dynamic> userListData = userInfoResponse.data['allUser'];
        userList = userListData.cast<Map<String, dynamic>>();
        userList.sort((a, b) => b['rating'].compareTo(a['rating']));
      });
    } catch (error) {
      print('Error fetching user list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 1,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 25),
            Text(
              'Ranking',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              constraints: BoxConstraints.expand(height: 50),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color.fromRGBO(255, 255, 255, 1),
                    unselectedLabelColor: Color.fromRGBO(21, 11, 61, 1),
                    indicator: BoxDecoration(
                      color: Color.fromRGBO(253, 163, 77, 1),
                    ),
                    tabs: const <Widget>[
                      Tab(
                        text: 'All Times',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  buildUserRankingList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserRankingList() {
    if (userList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      itemCount: userList.length,
      separatorBuilder: (context, index) => Divider(
        thickness: 2,
      ),
      itemBuilder: (context, index) {
        final userRanking = userList[index];
        double averageRating = double.parse(userRanking['rating'].toString());

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: userRanking['id'],
                ),
              ),
            );
          },
          child: ListTile(
            leading: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: CircleAvatar(
                child: Text(userRanking['name'][0]),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                '${userRanking['name']} ${userRanking['surname']}',
                style: TextStyle(
                  color: Color.fromRGBO(21, 11, 61, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userRanking['completedJobs']} Jobs Completed',
                  style: TextStyle(
                    color: Color.fromRGBO(116, 241, 18, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.star,
                          color: Color.fromRGBO(255, 184, 78, 1),
                          size: 30,
                        ),
                        Text(
                          ' ${averageRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
