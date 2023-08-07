import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/entities/user_list.dart';
import 'package:mobile/entities/skills.dart';
import 'package:mobile/components/skill_tag.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:mobile/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
class ProfileScreen extends StatefulWidget {
  final String userName;

  const ProfileScreen({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double coverHeight = 200;
  final double profileHeight = 144;
  User selectedUser = User(email: '', password: '', rating: 0);

  void initState() {
    super.initState();
    getUserById(widget.userName);
    print(widget.userName);
  }

  List<Widget> getSkillChips(List<String> skills) {
    List<Widget> skillChips = [];
    int chipsPerRow = 3;
    int rowCount = (skills.length / chipsPerRow).ceil();

    for (int i = 0; i < rowCount; i++) {
      int startIndex = i * chipsPerRow;
      int endIndex = (i + 1) * chipsPerRow;
      endIndex = endIndex < skills.length
          ? endIndex
          : skills
              .length; // Adjust endIndex if it exceeds the length of the skills list
      List<String> chipTexts = skills.sublist(startIndex, endIndex);

      skillChips.add(
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: chipTexts.map((text) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / chipsPerRow - 16.0,
              child: Chip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: Color.fromRGBO(233, 116, 80, 1),
              ),
            );
          }).toList(),
        ),
      );
    }
    return skillChips;
  }

  void getUserById(String id) async {
    Map<String, dynamic>? userData;
    Dio dio = Dio();
    var userinfoendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$id';
    var userskilssendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$id/UserCategories';
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      var userInfoResponse =
          await dio.get(userinfoendpointUrl, options: options);

      if (userInfoResponse.statusCode == 200) {
        var userInfo = userInfoResponse.data;
        print(userInfo);

        var userSkillsResponse =
            await dio.get(userskilssendpointUrl, options: options);

        var userSkills = <String>[];

        if (userSkillsResponse.statusCode == 200 &&
            userSkillsResponse.data['categoryNames'] != null) {
          userSkills = List<String>.from(
              userSkillsResponse.data['categoryNames'] as List<dynamic>);
        }

        setState(() {
          selectedUser = User(
              id: id,
              email: userInfo['email'],
              password: currentUser!.password,
              name: userInfo['name'],
              surname: userInfo['surname'],
              rating: userInfo['rating'],
              img: userInfo['image'].toString(),
              location: '',
              skills: userSkills,
              completedJobs: userInfo['completedJobs'],
              number: userInfo['phoneNumber'],);

        });
      } else {
        // Handle the error case
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Failed to get user information',
          ),
        );
      }
    } catch (error) {
      // Handle any exceptions or errors that occur during the request
      print(error);
    }
  }

  void _selectProfileImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () {
                    _getImageFromSource(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () {
                    _getImageFromSource(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateProfileImage(String image) async {
    final dio = Dio();
    final token = 'Bearer ${currentUser!.token}}';
    print(widget.userName);
    print(image);
    final data = {
      "id": widget.userName,
      "name": selectedUser.name,
      "surname": selectedUser.surname,
      "email": selectedUser.email,
      "image": image,
      "password": currentUser!.password,
    };

    try {
      var userinfoendpointUrl =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account';
      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

      var userInfoResponse =
          await dio.put(userinfoendpointUrl, data: data, options: options);

      print(userInfoResponse.data);

      setState(() {
        selectedUser.img = image;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _getImageFromSource(ImageSource source) async {
    final pickedImage = await ImagePicker().getImage(source: source);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final imageBase64 = base64Encode(bytes);
      _updateProfileImage(imageBase64);
    }
  }

  void openUpdateDialog(BuildContext context) {
    String name = selectedUser.name;
    String surname = selectedUser.surname;
    String password = currentUser!.password;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                  controller: TextEditingController(text: name),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Surname'),
                  onChanged: (value) {
                    surname = value;
                  },
                  controller: TextEditingController(text: surname),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Password'),
                  onChanged: (value) {
                    password = value;
                  },
                  controller: TextEditingController(text: password),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Prepare the payload
                      Map<String, dynamic> payload = {
                        "id": widget.userName,
                        "name": name,
                        "surname": surname,
                        "password": password,
                      };

                      // Create Dio instance
                      Dio dio = Dio();

                      // Set authorization header
                      dio.options.headers = {
                        'Authorization': 'Bearer ${currentUser!.token}',
                      };

                      try {
                        // Make the PUT request
                        Response response = await dio.put(
                          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account',
                          data: payload,
                        );

                        if (response.statusCode == 200) {
                          setState(() {
                            getUserById(widget.userName);
                          });
                          Navigator.of(context).pop();
                        } else {
                          // Update failed
                          // Handle the error condition
                        }
                      } catch (error) {
                        print(error);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(243, 116, 81, 1),
                    ),
                    child: Text('Update'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        buildTop(),
        buildContent(context),
      ],
    ));
  }

  Widget buildTop() {
    final bottom = profileHeight / 3;
    final top = coverHeight - profileHeight / 1.5;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top - 60,
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),
        if (widget.userName == currentUser!.id)
          Positioned(
            top: top - 60,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: Text('Update User Information'),
                        value: 1,
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          openUpdateDialog(
                              context); // openUpdateDialog metodu çağırılıyor
                          break;
                      }
                    },
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    {
                      currentUser = User(
                          id: '',
                          img: '',
                          email: '',
                          password: '',
                          name: '',
                          surname: '',
                          rating: -1,
                          completedJobs: -1,
                          skills: []);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          selectedUser.name + ' ' + selectedUser.surname + ' ',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width / 4,
          child: Chip(
            backgroundColor: Colors.green,
            label: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white),
                  Expanded(
                    child: Text(
                      selectedUser.completedJobs.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Skills and Interests',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        if (widget.userName == currentUser!.id)
                          SizedBox(
                            height: 30,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(255, 184, 78, 1),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SkillTagPage(
                                      userName: widget.userName,
                                    ),
                                  ),
                                ).then((eklenenTagler) {
                                  if (eklenenTagler != null) {
                                    setState(() {
                                      getUserById(widget.userName);
                                    });
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Add More'),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: 100,
                      alignment:
                          selectedUser.skills.isEmpty ? Alignment.center : null,
                      child: selectedUser.skills.isEmpty
                          ? Text(
                              "No skills added yet.",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: getSkillChips(selectedUser.skills),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16.0),
                        Icon(
                          Icons.star,
                          color: Colors.yellow[700],
                          size: 76.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          selectedUser.rating.toStringAsFixed(
                              1), // Accessing the averageRating from the widget
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 36.0,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Color.fromRGBO(243, 116, 81, 1),
        width: double.infinity,
        height: coverHeight,
      );

  Widget buildProfileImage() {
    final image = selectedUser.img;
    bool isHaveImage = false;

    if (selectedUser.img != 'null' && selectedUser.img != null) {
      isHaveImage = true;
    }

    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
      ),
      child: InkWell(
        onTap: () {
          _selectProfileImage();
        },
        child: isHaveImage
            ? CircleAvatar(
                radius: profileHeight / 2,
                backgroundImage:
                    image != '' ? MemoryImage(base64Decode(image)) : null,
                    child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.call_end_outlined),
                          color: Colors.white,
                          onPressed: () {
                            String phoneNumber = selectedUser.number;
                            print(phoneNumber);
                            launch('tel:$phoneNumber');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : CircleAvatar(
                radius: profileHeight / 2,
                backgroundColor: Colors.grey,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.call_end_outlined),
                          color: Colors.white,
                          onPressed: () {
                            String phoneNumber = selectedUser.number;
                            print(phoneNumber);
                            launch('tel:$phoneNumber');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
