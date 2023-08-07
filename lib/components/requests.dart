import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/entities/User.dart';
import 'package:mobile/functions/get_job_icon.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:mobile/components/slider.dart';
import 'package:mobile/functions/open_map.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<Map<String, dynamic>> filteredJobs = [];
  int _selectedIndex = -1;
  String selectedUserId = '';
  void openGoogleMaps(String address) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';

    try {
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch Google Maps: $googleMapsUrl';
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
    }
  }

  void sendRequest(
    String jobId,
    String doerId,
  ) async {
    Dio dio = Dio();

    print(jobId + '-' + doerId);

    try {
      String updateurl =
          "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/$jobId/$doerId/JobOwnerAcceptingRequest";
      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
      var responseUpdate = await dio.post(updateurl, options: options);
      print('Request sent successfully');
       await updateFilteredJobs();
    } catch (error) {
      // Error occurred
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    updateFilteredJobs();
  }

  Future<List<dynamic>> updateFilteredJobs() async {
    Dio dio = Dio();
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs";

    dio.options.headers["Authorization"] = "Bearer ${currentUser!.token}";

    try {
      Response response = await dio.get(url, queryParameters: {
        'Pagination.Page': 0,
        'Pagination.Size': 100,
      });

      if (response.statusCode == 200) {
        print('başarılı şekilde tamamlandı');
        Map<String, dynamic> responseData = response.data;
        List<dynamic> backendJobs = responseData['jobs'];

        // Filtreleme işlemi
        List<dynamic> filteredJobs = backendJobs
            .where((job) =>
                (job['ownerId'] == currentUser!.id ||
                    job['jobPosterRequest'] == currentUser!.id) &&
                job['status'] == "Pending")
            .toList();
        print(filteredJobs);

        for (var job in filteredJobs) {
          print(job);
        }
        return filteredJobs;
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  Future<List<dynamic>> getJobImages(String jobId) async {
    Dio dio = Dio();
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs/$jobId/Images";
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      Response response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        List<dynamic> jobImages = response.data['jobImages'];
        return jobImages;
      } else {
        throw Exception('Failed to fetch job images');
      }
    } catch (e) {
      throw Exception('Failed to fetch job images: $e');
    }
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) async {
    final Size screenSize = MediaQuery.of(context).size;
    int selectedRating = 0;

    Dio dio = Dio();
    var userinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/${job['ownerId']}';
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
    var userInfoResponse = await dio.get(userinfoendpointUrl, options: options);
    var userInfo = userInfoResponse.data;
    print(job['id']);
    var getRequests =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/${job['id']}/JobDoerRequest';
    var getRequestsResponse = await dio.get(getRequests, options: options);
    print(getRequestsResponse.data['userId']);
    List<dynamic> jobImages = await getJobImages(job['id']);
    List<String> userIds = getRequestsResponse.data['userId'].cast<String>();

    List<Map<String, dynamic>> userDetails = [];

    for (var userId in userIds) {
      var userEndpoint =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$userId';

      try {
        var userResponse = await dio.get(userEndpoint, options: options);
        if (userResponse.statusCode == 200) {
          var user = userResponse.data;

          userDetails.add({
            'id': userId.toString(),
            'name': user['name'],
            'surname': user['surname'],
          });
        } else {
          // Kullanıcı kaydı bulunamadı, userDetails içini boş tut
          userDetails = [];
          break;
        }
      } catch (e) {
        // İstek hatası, userDetails içini boş tut
        userDetails = [];
        break;
      }
    }

    print(userDetails);

    showDialog(
      context: context,
      barrierColor: Color.fromRGBO(233, 116, 81, 1),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job['title'],
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                    child: Container(
                  width: screenSize.width * 0.95,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(),
                        Text(
                          job['jobType'],
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.0),
                        CustomCarousel(
                            images: List<String>.from(
                                jobImages.map((image) => image.toString()))),
                        Divider(),
                        Text(
                          job['description'],
                          textAlign: TextAlign.center,
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 50.0), // Adjust the value as needed
                                child: Center(
                                  child: Text(
                                    job['location'],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('lib/assets/google-maps.png'),
                              onPressed: () {
                                openGoogleMaps(job['location']);
                              },
                            ),
                          ],
                        ),
                        Divider(),
                        Text(
                          job['price'].toString() + '₺',
                          textAlign: TextAlign.center,
                        ),
                        Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Poster Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                    // Kullanıcının profil resmi
                                    ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(userInfo['name'] +
                                      ' ' +
                                      userInfo['surname']),
                                ),
                                Spacer(),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Job Doer Requests',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child: ListView.builder(
                                    itemCount: userDetails.length,
                                    itemBuilder: (context, index) {
                                      final user = userDetails[index];
                                      final name = user['name'];
                                      final surname = user['surname'];
                                      final id = user['id'];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                            selectedUserId = id;
                                            print(
                                                'Selected user id: $selectedUserId');
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 4.0,
                                          ),
                                          child: Container(
                                            color: _selectedIndex == index
                                                ? Colors.deepOrange.shade300
                                                : Colors.transparent,
                                            child: Row(
                                              children: [
                                                CircleAvatar(),
                                                SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('$name $surname'),
                                                ),
                                                Spacer(),
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 3.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Container(
                                                      height: 30,
                                                      child: Image.asset(
                                                          'lib/assets/chat-24.png'),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (job['ownerId'] == currentUser!.id) {
                                        sendRequest(
                                          job['id'],
                                          selectedUserId,
                                        );
                                        Navigator.pop(context);

                                      }
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text('Accept',
                                          style: TextStyle(fontSize: 16.0)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text('Reject',
                                          style: TextStyle(fontSize: 16.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                          ],
                        ),
                      ]),
                )));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: updateFilteredJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              width: 50, // İstediğiniz genişliği ayarlayın
              height: 50, // İstediğiniz yüksekliği ayarlayın
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          filteredJobs = List<Map<String, dynamic>>.from(snapshot.data!);

          return filteredJobs.length > 0 ? ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              final id = job['id'];
              final title = job['title'] ?? 'N/A';
              final description = job['description'] ?? 'N/A';
              final payment = job['price'] ?? 'N/A';
              final address = job['address'] ?? 'N/A';
              final city = job['city'] ?? 'N/A';
              final district = job['district'] ?? 'N/A';
              final neighbourhood = job['neighbourhood'] ?? 'N/A';
              final status = job['status'] ?? 'N/A';
              final jobType = job['jobType'];
              bool isDismissed = false;
              final jobIcon = getJobIcon(jobType);
              final statusColor = status;

              return Dismissible(
                key: Key(id!.toString()),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                  } else if (direction == DismissDirection.startToEnd) {
                    // Silme işlemi

                    updateFilteredJobs();
                  }
                },
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    return false;
                  }
                  return true;
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    _showJobDetails(context, job);
                  },
                  leading: Icon(
                    jobIcon,
                    color: Colors.black,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(description),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '$payment ₺',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ): Center(
  child: Image.asset(
    'lib/assets/empty.png',
    width: 250, 
    height: 250, 
  ),
);
        }
      },
    );
  }
}
