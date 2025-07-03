import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:teciza_hr/screens/attendance_screen.dart';
import 'package:teciza_hr/screens/home_screen.dart';
import 'package:teciza_hr/screens/login_screen.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/preferences.dart';
import 'package:teciza_hr/utils/snackbar_helper.dart';
import 'package:teciza_hr/widgets/profile_info.dart';
import 'package:http/http.dart' as http;

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // const DashboardScreen(),
    AttendanceScreen(),
    ProfileInfo(),
    Text('Logging out...', style: TextStyle(fontSize: 24)), 
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _signout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  
  Future<void> _signout() async {
    try {
      final token = await Preferences.getData<String>('token');

      final response = await http.post(
        Uri.parse('${AppApiService.baseUrl}/method/traffictech.api.portal.auth.logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token'
        }
      );

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // if (!data['message']['success']) {
        //   _showSnackBar(data['message']['message']);
        // } else {
          await Preferences.clearAllData();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        // }
      }
    } catch (e) {
      _showSnackBar('An error occurred 3: $e');
    }
  }

  void _showSnackBar(String message) {
    SnackBarHelper.showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:  ClipRRect(
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
              backgroundColor: AppColors.black,
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_calendar_later_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_calendar_later_filled),
              backgroundColor: AppColors.black,
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
              backgroundColor: AppColors.black,
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_power_regular),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex == 3 ? 0 : _selectedIndex, 
          selectedItemColor: AppColors.goldenYellow,
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.transparent, // Make the background transparent
          showUnselectedLabels: true,
          // elevation: 0, 
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
