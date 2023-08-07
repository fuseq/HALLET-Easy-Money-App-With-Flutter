import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/functions/get_job_icon.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:mobile/variables/currency.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/components/slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AcceptedJobsPage extends StatefulWidget {
  @override
  _AcceptedJobsPageState createState() => _AcceptedJobsPageState();
}

class _AcceptedJobsPageState extends State<AcceptedJobsPage> {
  List<Map<String, dynamic>> filteredJobs = [];
  Uint8List? selectedImage;
  var doerInfo;
  var ownerInfo;
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

  @override
  void initState() {
    super.initState();
    updateFilteredJobs();
  }

  void completeJob(String id) async {
    try {
      var dio = Dio();
      var url =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/$id/SetComplete';

      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

      var response = await dio.put(url,options: options);

      if (response.statusCode == 200) {
        setState(() {
          updateFilteredJobs();
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'Job Completed',
          ),
        );
      } else {
        // Hata yanıtı
        print(
            'Job güncellenirken bir hata oluştu. Yanıt kodu: ${response.statusCode}');
      }
    } catch (e) {
      // Hata
      print('Bir hata oluştu: $e');
    }
  }
  void setRating(String id,int rating) async {
    try {
      var dio = Dio();
      var url =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/Rating';

      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

      var data = {
        'jobId': id,
        'rating': rating,
      };

      var response = await dio.put(url, data: data, options: options);

      if (response.statusCode == 200) {
        print('Job güncellendi: $id');
        setState(() {
          updateFilteredJobs();
        });

      } else {
        // Hata yanıtı
        print(
            'Job güncellenirken bir hata oluştu. Yanıt kodu: ${response.statusCode}');
      }
    } catch (e) {
      // Hata
      print('Bir hata oluştu: $e');
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

  void showRatingDialog(BuildContext context,String id) {
    double _rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rate the Job'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How would you rate this job?'),
              SizedBox(height: 16.0),
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  _rating = value;
                  print(_rating);
                },
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setRating(id, _rating.toInt());
                  Navigator.of(context).pop();
                  print('Selected rating: $_rating');
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(233, 116, 81, 1),
                ),
                child: Text('Submit'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) async {
    final Size screenSize = MediaQuery.of(context).size;
    int selectedRating = 0;

    Dio dio = Dio();
    var ownerinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/${job['ownerId']}';
    print({job['doerId']});
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
                                    left: 50.0), 
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
                             Text(
                              'Job Poster Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
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
                            if (job['ownerId'] == currentUser!.id)
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      completeJob(job['id']);
                                      Navigator.pop(context);
                                      setState(() {
                                        updateFilteredJobs();
                                      });
                                      showRatingDialog(context,job['id']);
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
                                        Colors.green,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'Complete Job',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
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
                  ),
                ));
          },
        );
      },
    );
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

        List<dynamic> filteredJobs = backendJobs
            .where((job) =>
                (job['ownerId'] == currentUser!.id ||
                    job['doerId'] == currentUser!.id) &&
                job['status'] == 'Accepted')
            .toList();
        print(filteredJobs);

        for (var job in filteredJobs) {}
        return filteredJobs;
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: updateFilteredJobs(),
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

              return Container(
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
          ):Center(
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
