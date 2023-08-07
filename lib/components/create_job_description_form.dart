import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:mobile/variables/job_types.dart';
import 'package:mobile/variables/currency.dart';

class CreateJobDescriptionForm extends StatefulWidget {
  static String title = '';
  static String jobType = '';
  static String description = '';
  static String payment = '';
  static String currency = '';
  static List<String> selectedImages = [];

  static void clearFields() {
    title = '';
    jobType = '';
    description = '';
    payment = '';
    currency = '';
  }

  @override
  _CreateJobDescriptionFormState createState() =>
      _CreateJobDescriptionFormState();
}

class _CreateJobDescriptionFormState extends State<CreateJobDescriptionForm> {
  String? _selectedJobType;
  String? _selectedCurrency;
  final List<String> _options = job_types;
  final List<String> _currency = currencies;

  Future<void> pickImages() async {
    try {
      List<XFile>? images = await ImagePicker().pickMultiImage();
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);
          CreateJobDescriptionForm.selectedImages.add(base64Image);
        }
        setState(() {});
      }
    } on PlatformException catch (e) {
      print('Hata: $e');
    }
  }

  void removeImage(int index) {
    setState(() {
      CreateJobDescriptionForm.selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Title',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Your Job Title',
            ),
            onChanged: (value) {
              setState(() {
                CreateJobDescriptionForm.title = value;
              });
            },
          ),
          SizedBox(height: 16.0),
          Text(
            'Job Type',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          DropdownButtonFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
              hintText: 'Select an option',
            ),
            value: _selectedJobType,
            items: _options
                .map(
                  (option) => DropdownMenuItem(
                    child: Text(option),
                    value: option,
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                CreateJobDescriptionForm.jobType = value.toString();
                _selectedJobType = value;
              });
            },
          ),
          SizedBox(height: 16.0),
          Text(
            'Job Details',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Your Job Details',
            ),
            onChanged: (value) {
              setState(() {
                CreateJobDescriptionForm.description = value;
              });
            },
          ),
          SizedBox(height: 16.0),
          Text(
            'Payment',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Payment Price',
                  ),
                  onChanged: (value) {
                    setState(() {
                      CreateJobDescriptionForm.payment = value;
                    });
                  },
                ),
              ),

            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => pickImages(),
            child: Text(
              'Select Images',
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
          ),
          SizedBox(height: 16.0),
          Text(
            'Selected Images',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: CreateJobDescriptionForm.selectedImages.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => removeImage(index),
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.memory(
                    base64Decode(
                        CreateJobDescriptionForm.selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
