import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile/variables/cities.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
class CreateJobAddressForm extends StatefulWidget {
  static String address = '';
  static String city = '';
  static String district = '';
  static String neighbourhood = '';

  static void clearFields() {
    address = '';
    city = '';
    district = '';
    neighbourhood = '';
  }

  @override
  _CreateJobAddressFormState createState() => _CreateJobAddressFormState();
}

class _CreateJobAddressFormState extends State<CreateJobAddressForm> {
  String? _selectedCity;
  String? _selectedDistrict;

  List<String> _city = Cities.cities;
  Map<String, List<String>> districts = Cities.districts;


  List<String> _district = [];
  List<String> _neighbourhood = [];

  TextEditingController _addressController = TextEditingController();

  void _updateDistricts(String selectedCity) {
    setState(() {
      _selectedCity = selectedCity;
      _selectedDistrict = null;
      _district = districts[selectedCity] ?? [];
      _neighbourhood = [];
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedCity = _city.first;
    _district = districts[_selectedCity] ?? [];
    _addressController.text = CreateJobAddressForm.address;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permission denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permission denied forever';
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String address = await getAddress(position.latitude, position.longitude);
    return address;
  }

  Future<String> getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];

    String address = '${place.street} ${place.subLocality}, ${place.locality}';
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Address',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              icon: Image.asset(
                'lib/assets/google-maps.png',
                height: 24,
              ),
              label: Text(
                'Get location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange.shade400,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                String address = await getCurrentLocation();
                setState(() {
                  CreateJobAddressForm.address = address;
                  _addressController.text = address;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter Your Address',
          ),
          onChanged: (value) {
            setState(() {
              CreateJobAddressForm.address = value;
            });
          },
        ),
        Text(
          'City',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
 Container(
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
              hintText: 'Select an option',
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
              _updateDistricts(value.toString());
              setState(() {
                _selectedCity = value.toString();
                CreateJobAddressForm.city = value.toString();
              });
            },
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          'District/Neighbourhood',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                  hintText: 'Select an option',
                ),
                value: _selectedDistrict,
                items: _district
                    .map(
                      (district) => DropdownMenuItem(
                        child: Text(district),
                        value: district,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value.toString();
                    CreateJobAddressForm.district = value.toString();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
