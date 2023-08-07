import 'package:flutter/material.dart';
import 'main.dart';
import 'sign_up_page.dart';
import 'package:mobile/entities/user.dart';
import 'package:mobile/entities/user_list.dart';
import 'package:mobile/variables/logged_in_user.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool securePassword = true;

  void loginUser() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      Dio dio = Dio();
      var loginendpointUrl =
          'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/login';

      var payload = {
        'email': email,
        'password': password,
      };

      var response = await dio.post(loginendpointUrl, data: payload);

      if (response.statusCode == 200) {
        var id = response.data['id'];
        var token = response.data['token'];
        print('Token: $token');

        var userinfoendpointUrl =
            'https://cleanarchitecturewebapi20230516150341.azurewebsites.net/api/Account/$id';
        var options = Options(headers: {'Authorization': 'Bearer $token'});

        var userInfoResponse =
            await dio.get(userinfoendpointUrl, options: options);
        var userInfo = userInfoResponse.data;
        print('Kullanıcı Bilgileri: $userInfo');

  setState(() {
      currentUser = User(
          token: token,
          id :id,
          email: userInfo['email'],
          password: passwordController.text,
          name: userInfo['name'],
          surname: userInfo['surname'],
          rating:  userInfo['rating'] ,
          img: userInfo['image'].toString(),
          number: userInfo['phoneNumber'] 
    );});
        // Giriş başarılı oldu
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // Giriş başarısız oldu
        ScaffoldMessengerState scaffoldMessenger =
            ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Invalid email or password.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                        "Welcome to HALLET",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800]),
                      ),
                      Container(
                        height: height * .25,
                        width: width,
                        decoration: const BoxDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 30,
                            child: Image.asset('lib/assets/tool-box.png'),
                          ),
                        ),
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
                          suffixIcon:
                              Icon(Icons.email_outlined, color: Colors.black),
                        ),
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forget your password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
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
                          onPressed: loginUser,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Login',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
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
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SignUpPage()));
                            },
                            child: const Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
