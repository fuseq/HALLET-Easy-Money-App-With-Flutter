import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:mobile/components/popular_jobs.dart';
import 'package:mobile/components/filter_drawer.dart';
import 'package:mobile/screens/ranking.dart';
import 'package:mobile/functions/open_map.dart';
import '../components/slider.dart';

class HomeScreen extends StatefulWidget {
  static double minPrice = 0.0;
  static double maxPrice = 0.0;
  static String? selectedJobType;
  static String? selectedCity;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = '';
  Future<List<dynamic>>? jobsFuture;
  void _applyFilters(
    String? selectedJobType,
    double minPrice,
    double maxPrice,
    String? selectedCity,
  ) {
    HomeScreen.minPrice = minPrice;
    HomeScreen.maxPrice = maxPrice;
    HomeScreen.selectedJobType = selectedJobType;
    HomeScreen.selectedCity = selectedCity;
    setState(() {
      jobsFuture = getFilteredJobs(selectedCity.toString(), minPrice, maxPrice,
          selectedJobType.toString());
    });
  }

  void initState() {
    super.initState();
    jobsFuture = getJobs();
  }

  Future<List<dynamic>> getJobs() async {
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
        for (var job in backendJobs) {
          print(job);
        }
        return backendJobs;
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  String _getTimeSince(String dateString) {
    final date = DateTime.parse(dateString);
    final duration = DateTime.now().difference(date);
    if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  void sendRequest(
    String jobId,
    String doerId,
    String title,
    String jobType,
    String status,
    String description,
    int price,
    int jobPosterRating,
  ) async {
    Dio dio = Dio();

    try {
      String requesturl =
          "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/JobWorkflow/JobDoerRequest";
      var request = {
        'jobId': jobId,
        'userId': doerId,
      };
      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
      var responseRequest =
          await dio.post(requesturl, data: request, options: options);
      print('Request sent successfully');
    } catch (error) {
      // Error occurred
      print('Error: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getFilteredJobs(
    String city,
    double minPrice,
    double maxPrice,
    String category,
  ) async {
    Dio dio = Dio();
    print(city +
        '-' +
        minPrice.toString() +
        '-' +
        maxPrice.toString() +
        '-' +
        category.toString());
    String url =
        "https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Filter/filter";
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
    Map<String, dynamic> queryParams = {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
    if (city.toString() != 'null') {
      queryParams['cities'] = city;
    }
    if (category.toString() != 'null') {
      queryParams['categories'] = category;
    }

    try {
      Response response = await dio.get(
        url,
        options: options,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> jobList =
            List<Map<String, dynamic>>.from(response.data);
        print(jobList.toString());
        return jobList;
      } else {
        throw Exception('Failed to fetch job images');
      }
    } catch (e) {
      throw Exception('Failed to fetch job images: $e');
    }
  }

  String _getDescription(String description) {
    if (description.length > 50) {
      return description.substring(0, 50) + '...';
    } else {
      return description;
    }
  }

Future<List<dynamic>> fetchSearchedJobs(String searchText) async {
  print(searchText);
  final url = 'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Filter/search';

  final dio = Dio();
  dio.options.headers["Authorization"] = "Bearer ${currentUser!.token}";

  try {
    final response = await dio.get(url, queryParameters: {
      'keywords': searchText,
    });

    if (response.statusCode == 200) {
      final data = response.data;
      print(data);
      return data as List<dynamic>;
    } else {
      throw Exception('Failed to fetch filtered jobs');
    }
  } catch (e) {
    throw Exception('Failed to fetch filtered jobs: $e');
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

  void _showDialog(BuildContext context, Map<String, dynamic> job) async {
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
                        job['jobType'].toString(),
                        textAlign: TextAlign.center,
                      ),
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
                                  job['location'].toString(),
                                  textAlign: TextAlign.center,
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
                                child: Text(
                                  userInfo['name'] + ' ' + userInfo['surname'],
                                ),
                              ),
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
                      Divider(),
                      ElevatedButton(
                        onPressed: () {
                          sendRequest(
                              job['id'],
                              currentUser!.id,
                              job['title'],
                              job['jobType'],
                              job['status'],
                              job['description'],
                              job['price'],
                              job['jobPosterRating']);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16.0),
                          primary: Colors.green,
                        ),
                        child: Icon(Icons.handshake,
                            size: 30.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FilterDrawer(
                        applyFiltersCallback: _applyFilters,
                      );
                    },
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(Icons.filter_list, color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepOrange,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    cursorColor: Colors.deepOrange,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserRankingScreen()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 30,
                      child: Image.asset('lib/assets/ranking.png'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          child: PopularJobs(),
        ),
Expanded(
  child: Container(
    child: Column(
      children: [
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: searchText.isEmpty ? jobsFuture : fetchSearchedJobs(searchText),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<dynamic> availableJobs = [];

                if (snapshot.hasData) {
                  availableJobs = snapshot.data!;
                }

                return ListView.separated(
                  itemCount: availableJobs.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(thickness: 2);
                  },
                  itemBuilder: (context, index) {
                    final job = availableJobs[index];
                    final title = job['title'] ?? 'N/A';
                    final description = job['description'] ?? 'N/A';
                    final payment = job['payment'] ?? 'N/A';
                    final currency = job['currency'] ?? 'N/A';
                    final address = job['address'] ?? 'N/A';
                    final city = job['city'] ?? 'N/A';
                    final district = job['district'] ?? 'N/A';
                    final neighbourhood = job['neighbourhood'] ?? 'N/A';
                    final status = job['status'] ?? 'N/A';
                    final jobType = job['jobType'];
                    final createdBy = job['createdBy'];

                    return ListTile(
                      leading: Icon(Icons.work),
                      title: Text(
                        job['title'],
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _getDescription(job['description']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0),
                      ),
                      trailing: Column(
                        children: [
                          Text(
                            _getTimeSince(job['createdDate']),
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 6),
                          Text(
                            job['price'].toString() + '₺',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showDialog(context, job);
                        print('Min Price: ${HomeScreen.minPrice}');
                        print('Max Price: ${HomeScreen.maxPrice}');
                        print('Selected Job Type: ${HomeScreen.selectedJobType}');
                        print('Selected City: ${HomeScreen.selectedCity}');
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    ),
  ),
)
      ],
    );
  }
}
