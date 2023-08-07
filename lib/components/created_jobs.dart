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

class CreatedJobsPage extends StatefulWidget {
  @override
  _CreatedJobsPageState createState() => _CreatedJobsPageState();
}

class _CreatedJobsPageState extends State<CreatedJobsPage> {
  List<Map<String, dynamic>> filteredJobs = [];
  Uint8List? selectedImage;
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

  void deleteItem(String id) async {
    Dio dio = Dio();
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs/$id/";
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      Response response = await dio.delete(url, options: options);

      if (response.statusCode == 200) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'Job Removed Successfully',
          ),
        );
      } else {
        throw Exception('Failed to remove job');
      }
    } catch (e) {
      throw Exception('Failed to remove job: $e');
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
                                padding: EdgeInsets.only(left: 50.0),
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
                                  backgroundImage: job['image'] != null
                                      ? MemoryImage(base64Decode(job['image']))
                                      : null,
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

  void _showEditJobDialog(BuildContext context, Map<String, dynamic> job) {
    String title = job['title'];
    String description = job['description'];
    String? jobType = job['jobType'];
    String payment = job['price'].toString();
    String? selectedCurrency;
    String? _selectedJobType;
    final List<String> _jobTypes = [
      'Pet Sitting',
      'Plumbing',
      'Cleaning',
      'Gardening',
      'Delivery',
      'Painting'
    ];

    _selectedJobType = jobType; // Set the selected value
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Job',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your Job Title',
                    ),
                    onChanged: (value) {
                      title = value;
                    },
                    controller: TextEditingController(text: title),
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Your Job Type',
                    ),
                    value: _selectedJobType, // Set the selected value
                    onChanged: (String? newValue) {
                      jobType = newValue;
                      print(jobType);
                    },
                    items: _jobTypes.map((String jobType) {
                      return DropdownMenuItem<String>(
                        value: jobType,
                        child: Text(jobType),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your Job Description',
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      description = value;
                    },
                    controller: TextEditingController(text: description),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your Payment',
                    ),
                    onChanged: (value) {
                      payment = value;
                    },
                    controller: TextEditingController(text: payment),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          updateJob(job['id'], title, jobType!, description,
                              int.parse(payment));
                          updateFilteredJobs();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void updateJob(String id, String title, String jobType, String description,
      int price) async {
    try {
      var dio = Dio();
      var url =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs';

      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

      var data = {
        'id': id,
        'title': title,
        'jobType': jobType,
        "status": "string",
        'description': description,
        'price': price,
        'jobPosterRating': 0,
        "jobDoerId": "string",
      };

      var response = await dio.put(url, data: data, options: options);

      if (response.statusCode == 200) {
        print('Job güncellendi: $id');
        setState(() {
          updateFilteredJobs();
        });
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'Job Updated Successfully',
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
            .where((job) => job['ownerId'] == currentUser!.id)
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

          return filteredJobs.length > 0
              ? ListView.builder(
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
                          deleteItem(id);
                          updateFilteredJobs();
                        }
                      },
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          _showEditJobDialog(context, job);
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
                )
              : Center(
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
