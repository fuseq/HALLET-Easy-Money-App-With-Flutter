import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/entities/user_list.dart';
import 'package:mobile/entities/skills.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var maskFormatter = new MaskTextInputFormatter(
      mask: '(###) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  List<String> selectedTags = [];
  bool securePassword = true;
  String generateRandomId() {
    Random random = Random();
    const String characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String randomId = '';

    for (int i = 0; i < 8; i++) {
      int randomIndex = random.nextInt(characters.length);
      randomId += characters[randomIndex];
    }

    return randomId;
  }

  String formatPhoneNumber(String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[()\s-]'), '');
    String areaCode = cleanedNumber.substring(0, 3);
    String firstPart = cleanedNumber.substring(3, 6);
    String secondPart = cleanedNumber.substring(6, 10);
    String formattedNumber = areaCode + firstPart + secondPart;

    return formattedNumber;
  }

  void registerUser(String name, String surname, String email, String password,
      String number) async {
    try {
      Dio dio = Dio();
      var endpointUrlforLogin =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/register';

      var payload = {
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
        'phoneNumber': formatPhoneNumber(number),
      };

      var responseLogin = await dio.post(endpointUrlforLogin, data: payload);

      if (responseLogin.statusCode == 200) {
        // İstek başarılı oldu
        print('Kayıt başarılı');
      } else {
        // İstek başarısız oldu
        print('Kayıt hatası: ${responseLogin.statusCode}');
      }
    } catch (error) {
      // Hata oluştu
      print('Hata: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Sign up",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800]),
                      ),
                      SizedBox(
                        height: height * 0.1,
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "EMAIL",
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "NAME",
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: surnameController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "SURNAME",
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      TextField(
                          controller: numberController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "PHONE NUMBER",
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.black,
                            ),
                          ),
                          inputFormatters: [maskFormatter]),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: securePassword,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: securePassword
                                ? const Icon(Icons.visibility_outlined)
                                : const Icon(Icons.visibility_off_outlined),
                            color: Colors.black,
                            onPressed: () {
                              setState(() {
                                securePassword = !securePassword;
                              });
                            },
                          ),
                          labelText: "PASSWORD",
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[800],
                            fixedSize: Size(width, height * 0.08),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registration Successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text('Register',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: const Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
