import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/functions/get_job_icon.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:mobile/components/slider.dart';
import 'package:url_launcher/url_launcher.dart';

class JobHistoryPage extends StatefulWidget {
  @override
  _JobHistoryPageState createState() => _JobHistoryPageState();
}

class _JobHistoryPageState extends State<JobHistoryPage> {
  var doerInfo;
  var ownerInfo;
  List<Map<String, dynamic>> finishedJobsAsPoster = [];
  List<Map<String, dynamic>> finishedJobsAsDoer = [];
  List<Map<String, dynamic>> rejectedJobsAsDoer = [];
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

  Future<List<String>> getRejectedJobIds() async {
    Dio dio = Dio();
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/${currentUser!.id}/JobRejectedRequest";
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      Response response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        List<String> jobIds = List<String>.from(response.data['jobIds']);
        print(jobIds);
        return jobIds;
      } else {
        throw Exception('Failed to fetch rejected job IDs');
      }
    } catch (e) {
      throw Exception('Failed to fetch rejected job IDs: $e');
    }
  }



 Future<List<Map<String, dynamic>>> getRejectedJobsAsDoer() async {
  Dio dio = Dio();
  try {
    List<dynamic> backendJobs = [];
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/${currentUser!.id}/JobRejectedRequest";
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    Response response = await dio.get(url, options: options);

    if (response.statusCode == 200) {
      List<String> jobIds = List<String>.from(response.data['jobIds']);
      backendJobs = jobIds;
    } else {
      throw Exception('Failed to fetch rejected job IDs');
    }

    final List<Map<String, dynamic>> rejectedJobsAsDoer = [];

    for (String jobId in backendJobs) {
      String jobUrl =
          "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs/$jobId";
      Response response = await dio.get(jobUrl, options: options);

      if (response.statusCode == 200) {
        Map<String, dynamic> jobData = response.data;
        rejectedJobsAsDoer.add(jobData);
      } else {
        throw Exception('Failed to fetch job details for ID: $jobId');
      }
    }

    return rejectedJobsAsDoer;
  } catch (e) {
    print('Failed to fetch rejected jobs as doer: $e');
    return [];
  }
}

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) async {
    final Size screenSize = MediaQuery.of(context).size;
    int selectedRating = 0;

    Dio dio = Dio();
    var ownerinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/${job['ownerId']}';
    var doerinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/${job['doerId']}';
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
    var ownerInfoResponse =
        await dio.get(ownerinfoendpointUrl, options: options);
    var doerInfoResponse = await dio.get(doerinfoendpointUrl, options: options);
    doerInfo = ownerInfoResponse.data;
    ownerInfo = doerInfoResponse.data;
    List<dynamic> jobImages = await getJobImages(job['id']);
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
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Doer Profile',
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
                                Text(ownerInfo['name'] +
                                    ' ' +
                                    ownerInfo['surname']),
                                Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      height: 30,
                                      child:
                                          Image.asset('lib/assets/chat-24.png'),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                            SizedBox(height: 8),
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
                                Text(doerInfo['name'] +
                                    ' ' +
                                    doerInfo['surname']),
                                Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      height: 30,
                                      child:
                                          Image.asset('lib/assets/chat-24.png'),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> updateFilteredJobs() async {
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
        print('Successfully completed');
        Map<String, dynamic> responseData = response.data;
        List<dynamic> backendJobs = responseData['jobs'];

        // Filtering operation
        List<Map<String, dynamic>> filteredJobs =
            List<Map<String, dynamic>>.from(backendJobs);

        print(filteredJobs);

        for (var job in filteredJobs) {
          // Process each job
        }
        return filteredJobs;
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFinishedJobsAsPoster() async {
    try {
      List<dynamic> backendJobs = await updateFilteredJobs();

      final finishedJobsByPoster = List<Map<String, dynamic>>.from(jobs_list
          .where((job) =>
              job['status'] == 'Completed' && job['ownerId'] == currentUser!.id)
          .toList());

      return finishedJobsByPoster;
    } catch (e) {
      print('Failed to fetch finished jobs as poster: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFinishedJobsAsDoer() async {
    try {
      List<dynamic> backendJobs = await updateFilteredJobs();

      final finishedJobsAsDoer = List<Map<String, dynamic>>.from(jobs_list
          .where((job) =>
              job['status'] == 'Completed' && job['doerId'] == currentUser!.id)
          .toList());

      return finishedJobsAsDoer;
    } catch (e) {
      print('Failed to fetch finished jobs as doer: $e');
      return [];
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
  future: updateFilteredJobs(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        
      );
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (snapshot.hasData) {
      List<Map<String, dynamic>> filteredJobs = snapshot.data!;

      return FutureBuilder<List<Map<String, dynamic>>>(
        future: getRejectedJobsAsDoer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> rejectedJobsAsDoer = snapshot.data!;

            final finishedJobsAsPoster = filteredJobs
                .where((job) =>
                    job['status'] == 'Completed' &&
                    job['ownerId'] == currentUser!.id)
                .toList();

            final finishedJobsAsDoer = filteredJobs
                .where((job) =>
                    job['status'] == 'Completed' &&
                    job['doerId'] == currentUser!.id)
                .toList();

            return ListView(
              children: [
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    'Finished Jobs as Poster',
                    style: TextStyle(color: Color.fromRGBO(233, 116, 80, 1)),
                  ),
                  iconColor: Color.fromRGBO(233, 116, 80, 1),
                  children: _buildJobListTiles(context, finishedJobsAsPoster),
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    'Finished Jobs as Doer',
                    style: TextStyle(color: Color.fromRGBO(233, 116, 80, 1)),
                  ),
                  iconColor: Color.fromRGBO(233, 116, 80, 1),
                  children: _buildJobListTiles(context, finishedJobsAsDoer),
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    'Rejected Job Requests',
                    style: TextStyle(color: Color.fromRGBO(233, 116, 80, 1)),
                  ),
                  iconColor: Color.fromRGBO(233, 116, 80, 1),
                  children: _buildJobListTiles(context, rejectedJobsAsDoer),
                ),
              ],
            );
          } else {
            return Text('No data');
          }
        },
      );
    } else {
      return Text('No data');
    }
  },
);
  }

  List<Widget> _buildJobListTiles(
      BuildContext context, List<Map<String, dynamic>> jobs) {
    return jobs.map((job) {
      final title = job['title'] ?? 'N/A';
      final description = job['description'] ?? 'N/A';
      final price = job['price'] ?? 'N/A';
      final jobType = job['jobType'];
      final jobIcon = getJobIcon(jobType);
      final isRejected =
          job['rejectedRequests']?.contains(currentUser!.email) ?? false;
      final status = isRejected ? 'rejected' : job['status'] ?? 'N/A';

      return ListTile(
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
                color: isRejected ? Colors.red : null,
              ),
            ),
            SizedBox(height: 5),
            Text(price.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }).toList();
  }
}
