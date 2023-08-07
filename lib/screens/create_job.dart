import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/components/create_job_description_form.dart';
import 'package:mobile/components/create_job_address_form.dart';
import 'package:mobile/entities/jobs_list.dart';
import 'package:mobile/entities/job.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
class CreateJobScreen extends StatefulWidget {
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();



void _createJob() async {
  if (_formKey.currentState != null) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      List<String> selected_images =
          List<String>.from(CreateJobDescriptionForm.selectedImages);
          
      var options =
          Options(headers: {'Authorization': 'Bearer ${currentUser!.token}'});
      // Create a Dio instance
      Dio dio = Dio();
      
      try {
        Response jobresponse = await dio.post(
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs',
          data: {
            'title': CreateJobDescriptionForm.title,
            'jobType': CreateJobDescriptionForm.jobType,
            'description': CreateJobDescriptionForm.description,
            'price': CreateJobDescriptionForm.payment,
            'ownerId': currentUser!.id,
            'location': CreateJobAddressForm.address +
                ',' +
                CreateJobAddressForm.district +
                ',',
            'city' :CreateJobAddressForm.city,
          },
          options: options,
        );

        // Check the response status
        if (jobresponse.statusCode == 200) {
          // Extract the jobId from the response
          String jobId = jobresponse.data['jobId'];

          // Make the second POST request to add job images
Response imageresponse = await dio.post(
  'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Jobs/Image',
  data: {
    'jobId': jobId,
    'jobImages': selected_images.map((image) => image.toString()).toList(),
  },
  options: options,
);


          // Check the response status
          if (imageresponse.statusCode == 200) {
            CreateJobDescriptionForm.clearFields();
            CreateJobAddressForm.clearFields();
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: 'Job Created Successfully',
              ),
            );
          } else {
            // Handle the error case
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: 'Failed to add job images',
              ),
            );
          }
        } else {
          // Handle the error case
          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message: 'Failed to create job',
            ),
          );
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
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Center(
                  child: Container(
                    child: Text(
                      'Create Job',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CreateJobDescriptionForm(),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: CreateJobAddressForm(),
                    ),
                    SizedBox(height: 32.0),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                child: Text('Create Job'),
                onPressed: _createJob,
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fixedSize: Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
