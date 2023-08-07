import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/entities/skills.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/entities/user_list.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../variables/logged_in_user.dart';

class SkillTagPage extends StatefulWidget {
  final String userName;

  SkillTagPage({required this.userName});

  @override
  _SkillTagPageState createState() => _SkillTagPageState();
}

class _SkillTagPageState extends State<SkillTagPage> {
  final TextEditingController _textEditingController = TextEditingController();
  String _newSkill = '';
  List<String> _skills = [];
  List<String> _predefinedTags = [];
  List<String> _selectedTags = [];

  void getUserById(String id) async {
    Dio dio = Dio();

    var userskilssendpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$id/UserCategories';
    var options =
        Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

    try {
      var userSkillsResponse =
          await dio.get(userskilssendpointUrl, options: options);

      if (userSkillsResponse.statusCode == 200 &&
          userSkillsResponse.data['categoryNames'] != null) {
        setState(() {
          _skills = List<String>.from(
              userSkillsResponse.data['categoryNames'] as List<dynamic>);
        });
      }
    } catch (error) {
      // Handle any exceptions or errors that occur during the request
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'An error occurred',
        ),
      );
    }
  }

  void _fetchPredefinedTags() async {
    Dio dio = Dio();

    var categoryEndpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Category';

    try {
      setState(() {
        _predefinedTags = ['Loading...'];
      });

      var response = await dio.get(
        categoryEndpointUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${currentUser!.token}'},
        ),
      );

      if (response.statusCode == 200 && response.data['jobTypes'] != null) {
        var jobTypes = response.data['jobTypes'] as List<dynamic>;
        var newPredefinedTags = <String>[];

        for (var jobType in jobTypes) {
          var categoryName = jobType['categoryName'] as String;
          newPredefinedTags.add(categoryName);
        }

        setState(() {
          _predefinedTags = newPredefinedTags;
        });
      }
    } catch (error) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'An error occurred',
        ),
      );
    }
  }

  void _updateUserSkills(String selected) async {
    Dio dio = Dio();

    var userCategoriesEndpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/Categories';
    List<String> selecteds = [];
    selecteds.add(selected);

    var payload = {
      'userId': widget.userName,
      'userSkills': selecteds,
    };
    selecteds = [];
    try {
      var response = await dio.post(
        userCategoriesEndpointUrl,
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer ${currentUser!.token}'},
        ),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        print("skill added successfully");
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'An error occurred',
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  void _removeUserSkills(String selected) async {
    Dio dio = Dio();
    String id = widget.userName;
    String catname = selected;

    var userCategoriesEndpointUrl =
        'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$id/$selected/Category';
    try {
      var response = await dio.delete(
        userCategoriesEndpointUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${currentUser!.token}'},
        ),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        print("skill removed successfully");
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'An error occurred',
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserById(widget.userName);
    _fetchPredefinedTags();
  }

  void _addSkill() {
    if (_newSkill.isNotEmpty && !_skills.contains(_newSkill)) {
      setState(() {
        _skills.add(_newSkill);
        _newSkill = '';
      });
    }
  }

  void _removeSkill(String skill) {
    print(skill + '-------------------------------');
    _removeUserSkills(skill);
    setState(() {
      _skills.remove(skill);
      if (!_predefinedTags.contains(skill)) {
        _predefinedTags.add(skill);
      }
    });
  }

  void _selectTag(String tag) {
    setState(() {
      if (!_selectedTags.contains(tag)) {
        _selectedTags.add(tag);
        _skills.add(tag);

        _predefinedTags.remove(tag);
      }
    });

    _updateUserSkills(
        tag); // _updateUserSkills fonksiyonunu setState dışına taşı
  }

  void _removeSelectedTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
      _skills.remove(tag);
      _predefinedTags.add(tag);
    });
  }

  List<String> get availableTags {
    return _predefinedTags.where((tag) => !_skills.contains(tag)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 116, 81, 1),
        title: Text('Skills'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _skills);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: (_skills.length / 3).ceil(),
                  itemBuilder: (context, index) {
                    final int startIndex = index * 3;
                    final int endIndex = (index + 1) * 3 < _skills.length
                        ? (index + 1) * 3
                        : _skills.length;
                    final skillsSubset = _skills.sublist(startIndex, endIndex);

                    return Row(
                      children: skillsSubset.map((skill) {
                        return Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 2,
                            ),
                            child: Chip(
                              label: Text(
                                skill,
                                style: TextStyle(color: Colors.white),
                              ),
                              onDeleted: () => _removeSkill(skill),
                              backgroundColor: Color.fromRGBO(243, 116, 81, 1),
                              deleteIconColor: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            Divider(thickness: 2),
            SizedBox(height: 16),
            Text(
              'Predefined Tags',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableTags.map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (isSelected) {
                    if (isSelected) {
                      _selectTag(tag);
                    } else {
                      _removeSelectedTag(tag);
                    }
                  },
                  selectedColor: Color.fromRGBO(243, 116, 81, 1),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
