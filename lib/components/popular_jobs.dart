import 'package:flutter/material.dart';

List<Map<String, dynamic>> jobsList = [
  {
    'jobType': 'Gardening',
  },
  {
    'jobType': 'Plumber',
  },
  {
    'jobType': 'Electricity',
  },
  {
    'jobType': 'Education',
  },
  {
    'jobType': 'Pet Sitting',
  },
  {
    'jobType': 'Outdoor',
  },
];

IconData getIconForJobType(String jobType) {
  switch (jobType) {
    case 'Gardening':
      return Icons.local_florist;
    case 'Plumber':
      return Icons.plumbing;
    case 'Electricity':
      return Icons.electrical_services;
    case 'Education':
      return Icons.medical_services;
    case 'Pet Sitting':
      return Icons.pets;
    case 'Outdoor':
      return Icons.trolley;
    default:
      return Icons.error;
  }
}

class PopularJobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 100,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 112, 66, 1.0),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Popular Jobs',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: jobsList.map((job) {
                IconData icon = getIconForJobType(job['jobType']);
                return Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 20.0),
                  child: Container(
                    width: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon),
                          SizedBox(height: 8),
                          Text(job['jobType'] ?? 'Unknown job'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(), // Display only the first 4 jobs
            ),
          ),
        ],
      ),
    );
  }
}
