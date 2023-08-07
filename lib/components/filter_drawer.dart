import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../variables/cities.dart';
import '../variables/logged_in_user.dart';

class FilterDrawer extends StatefulWidget {
  final Function(String?, double, double, String?) applyFiltersCallback;

  const FilterDrawer({required this.applyFiltersCallback});

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  List<String> _jobTypes = [];
  List<String> _selectedJobTypes = [];
  bool _isLoading = true;
  bool _isJobTypeExpanded = false;
  bool _isPriceRangeExpanded = false;
  bool _isCityExpanded = false;
  double _minPrice = 0.0;
  double _maxPrice = 0.0;
  String? _selectedCity;
  List<String> _city = Cities.cities;

  @override
  void initState() {
    super.initState();
    _loadJobTypes();
  }

  Future<void> _loadJobTypes() async {
    try {
      final dio = Dio();
      final url =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Category';
      final options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});

      final response = await dio.get(url, options: options);
      final jobTypes = response.data['jobTypes'];

      setState(() {
        _jobTypes = List<String>.from(jobTypes.map((jt) => jt['categoryName']));
        _isLoading = false;
      });
    } catch (error) {
      // Handle error appropriately
      print(error.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 112, 66, 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Filter Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: Text('Job Type'),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16.0),
            initiallyExpanded: _isJobTypeExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isJobTypeExpanded = expanded;
              });
            },
            trailing: Icon(
              _isJobTypeExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            children: _isLoading
                ? [
                    SizedBox(height: 16.0),
                    Center(child: CircularProgressIndicator()),
                  ]
                : _jobTypes
                    .map(
                      (jobType) => ListTile(
                        title: Text(jobType),
                        trailing: Checkbox(
                          value: _selectedJobTypes.contains(jobType),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _selectedJobTypes.add(jobType);
                              } else {
                                _selectedJobTypes.remove(jobType);
                              }
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
          ),
          ExpansionTile(
            title: Text('Price Range'),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16.0),
            initiallyExpanded: _isPriceRangeExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isPriceRangeExpanded = expanded;
              });
            },
            trailing: Icon(
              _isPriceRangeExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            children: [
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Min Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _minPrice = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Max Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          ExpansionTile(
            title: Text('City'),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16.0),
            initiallyExpanded: _isCityExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isCityExpanded = expanded;
              });
            },
            trailing: Icon(
              _isCityExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            children: [
              SizedBox(height: 16.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                  hintText: 'Select a city',
                ),
                value: _selectedCity,
                items: _city
                    .map(
                      (city) => DropdownMenuItem(
                        child: Text(city),
                        value: city,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value.toString();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final selectedJobTypesString = _selectedJobTypes.join(',');
              widget.applyFiltersCallback(
                selectedJobTypesString.isEmpty ? null : selectedJobTypesString,
                _minPrice,
                _maxPrice,
                _selectedCity,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              primary:
                  Color.fromRGBO(255, 112, 66, 1.0), // Eklenen renk özelliği
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
