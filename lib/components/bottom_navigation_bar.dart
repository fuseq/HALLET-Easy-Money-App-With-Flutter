import 'package:flutter/material.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/chat_screen.dart';
import 'package:mobile/screens/create_job.dart';
import 'package:mobile/screens/my_jobs.dart';
import 'package:mobile/screens/profile.dart';
import 'package:mobile/variables/logged_in_user.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomeScreen(),
    ChatScreen(),
    CreateJobScreen(),
    MyJobsScreen(),
    ProfileScreen(userName: currentUser!.id),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Color.fromRGBO(233, 116, 81, 1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  child: Image.asset(
                    'lib/assets/home-24.png',
                    color: Colors.black,
                  ),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Color.fromRGBO(233, 116, 81, 1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  child: Image.asset(
                    'lib/assets/chat-24.png',
                    color: Colors.black,
                  ),
                ),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Color.fromRGBO(233, 116, 81, 1)
                      : Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_outlined, color: Colors.black, size: 30),
              ),
              label: 'Create Job',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentIndex == 3
                      ? Color.fromRGBO(233, 116, 81, 1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  child: Image.asset(
                    'lib/assets/hammer-24.png',
                    color: Colors.black,
                  ),
                ),
              ),
              label: 'My Jobs',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _currentIndex == 4
                      ? Color.fromRGBO(233, 116, 81, 1)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  child: Image.asset(
                    'lib/assets/user-24.png',
                    color: Colors.black,
                  ),
                ),
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Color.fromRGBO(233, 116, 81, 1),
          unselectedItemColor: Colors.black,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}
