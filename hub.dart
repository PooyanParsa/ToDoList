import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'main.dart';
import 'task.dart';
import 'profile.dart';
import 'exam.dart';
import 'setting.dart';

class HubPage extends StatefulWidget {
  final String username;

  HubPage({required this.username});

  @override
  _HubPageState createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  bool _showNameContainer = true;
  String? _fullName;
  final TextEditingController _fullNameController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadFullName();
  }

  Future<void> _saveFullName(String fullName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    setState(() {
      _fullName = fullName;
      _showNameContainer = false;
    });
  }

  Future<void> _loadFullName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('fullName') ?? null;
      if (_fullName != null) {
        _showNameContainer = false;
      }
    });
  }

  String? _validateFullName(String value) {
    final regex = RegExp(r'^[\u0600-\u06FF\s]+$');
    if (!regex.hasMatch(value)) {
      return 'لطفاً فقط حروف فارسی وارد کنید';
    }
    return null;
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.home, color: Colors.black),
        title: Text(
          _fullName != null
              ? 'خوش آمدی $_fullName'
              : 'خوش آمدی ${widget.username}',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Peyda',
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_showNameContainer)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_fullName == null) SizedBox(height: 50),
                _buildHubCard(context, Icons.list_alt, 'لیست کارها',
                    Colors.blue, TaskPage()),
                SizedBox(height: 16),
                _buildHubCard(context, Icons.person, 'پروفایل', Colors.green,
                    ProfilePage()),
                SizedBox(height: 16),
                _buildHubCard(context, Icons.bar_chart, 'آمار و گزارش‌ها',
                    Colors.orange, ExamPage()),
                SizedBox(height: 16),
                _buildHubCard(context, Icons.settings, 'تنظیمات', Colors.red,
                    SettingPage()),
              ],
            ),
          ),
          if (_showNameContainer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'لطفاً نام و نام خانوادگی خود را وارد کنید:',
                      style: TextStyle(
                          fontFamily: 'Peyda',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'نام و نام خانوادگی',
                        errorText: _validateFullName(_fullNameController.text),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: _validateFullName(_fullNameController.text) ==
                                  null
                              ? () {
                                  _saveFullName(_fullNameController.text);
                                }
                              : null,
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _validateFullName(_fullNameController.text) ==
                                          null
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                            ),
                            padding: EdgeInsets.all(8),
                            child:
                                Icon(Icons.arrow_forward, color: Colors.white),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHubCard(BuildContext context, IconData icon, String title,
      Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                  fontFamily: 'Peyda',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}
