import 'package:flutter/material.dart';

IconData getJobIcon(String jobType) {
  switch (jobType) {
    case 'Pet Sitting':
      return Icons.pets;
    case 'Plumbing':
      return Icons.build;
    case 'Cleaning':
      return Icons.cleaning_services;
    case 'Gardening':
      return Icons.eco;
    case 'Delivery':
      return Icons.local_shipping;
    case 'Painting':
      return Icons.format_paint;
    
    default:
      return Icons.work;
  }
}