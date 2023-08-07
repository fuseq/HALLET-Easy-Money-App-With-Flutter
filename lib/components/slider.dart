import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatelessWidget {
  late List<String> images;

  CustomCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        autoPlay: false,
      ),
      items: (images.isEmpty)
          ? [
              Image.asset(
                'lib/assets/no-img.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ]
          : images.map<Widget>((imageBase64) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.memory(
                    base64Decode(imageBase64),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  );
                },
              );
            }).toList(),
    );
  }
}