import 'package:mobile/entities/job.dart';

class User {
  String token;
  String id;
  String img;
  String email;
  String name;
  String surname;
  String password;
  int rating;
  List<String> skills;
  int completedJobs;
  String location;
  String number;

  User({
    this.token = '',
    this.id = '',
    required this.email,
    required this.password,
    this.img='',
    this.name='',
    this.surname='',
    this.location='',
    required this.rating,
    this.completedJobs = 0,
    this.skills = const [],
    this.number='',
  });

Map<String, dynamic> toMap() {
  return {
    'token': token,
    'id': id,
    'img': img,
    'email': email,
    'password': password,
    'name': name, 
    'surname': surname,  
    'rating': rating,
    'location': location,
    'completedJobs': completedJobs,
    'skills': skills,
    'number': number,
    
  };
}
}
