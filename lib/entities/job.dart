import 'dart:ffi';
import 'package:mobile/entities/user.dart';
class Job {
  String id;
  List<String> images;
  String title;
  String jobType;
  String description;
  String payment;
  String address;
  String city;
  String district;
  String status;
  String jobDoer;
  String jobPoster;
  String jobPosterRequest;
  List<String> jobDoerRequests;
  List<String> rejectedRequests;
  int jobDoerRating;
  int jobPosterRating;
  DateTime createdDate;
  DateTime? completedDate;

  Job({
    required this.id,
    required this.images,
    required this.title,
    required this.jobType,
    required this.description,
    required this.payment,
    required this.address,
    required this.city,
    required this.district,
    required this.status,
    required this.jobDoer,
    required this.jobPoster,
    required this.jobPosterRequest,
    required this.jobDoerRequests,
    required this.rejectedRequests,
    required this.jobDoerRating,
    required this.jobPosterRating,
    required this.createdDate,
    required this.completedDate,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'images': images,
      'title': title,
      'jobType': jobType,
      'description': description,
      'payment': payment,
      'address': address,
      'city': city,
      'district': district,
      'status': status,
      'jobDoer': jobDoer,
      'jobPoster': jobPoster,
      'jobPosterRequest': jobPosterRequest,
      'jobDoerRequests': jobDoerRequests,
      'rejectedRequests': rejectedRequests,
      'jobDoerRatingCompleted': jobDoerRating,
      'jobPosterRatingCompleted': jobPosterRating,
      'createdDate': createdDate,
      'completedDate': completedDate,
    };
  }
}
