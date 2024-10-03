import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/hub.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        fontFamily: 'Peyda',
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLogin = false;
  bool _showPasswordField = false;
  bool _showConfirmPasswordField = false;
  bool _passwordsMatch = true;
  String? _username;
  String? _password = '';
  String? _confirmPassword;
  bool _passwordVisible = false;
  bool _usernameExists = false;
  bool _loginValid = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    String? storedPassword = prefs.getString('password');

    if (storedUsername != null && storedPassword != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HubPage(username: storedUsername),
        ),
      );
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<void> _login() async {
    var user = await dbHelper.getUser(
        _usernameController.text, _passwordController.text);
    if (user != null) {
      _saveCredentials(_usernameController.text, _passwordController.text);
      setState(() {
        _loginValid = true;
      });
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HubPage(username: _usernameController.text)));
      });
    } else {
      setState(() {
        _loginValid = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('نام کاربری یا رمز عبور اشتباه است'),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  Future<void> _register() async {
    bool usernameExists =
        await dbHelper.checkUsernameExists(_usernameController.text);
    if (usernameExists) {
      setState(() {
        _usernameExists = true;
      });
    } else {
      setState(() {
        _usernameExists = false;
      });
      if (_password != _confirmPasswordController.text) {
        setState(() {
          _passwordsMatch = false;
        });
      } else {
        await dbHelper.registerUser(
            _usernameController.text, _password!, 'نام و نام خانوادگی');
        _saveCredentials(_usernameController.text, _password!);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HubPage(username: _usernameController.text)));
      }
    }
  }

  String? _validateUsername(String value) {
    final regex = RegExp(r'^[a-zA-Z]+$');
    if (!regex.hasMatch(value)) {
      return 'نام کاربری باید فقط شامل حروف انگلیسی باشد';
    }
    if (value.contains(' ')) {
      return 'فاصله بین حروف مجاز نیست';
    }
    if (value.contains(RegExp(r'[@#\$%\^&\*\(\)\[\]\{\}]'))) {
      return 'استفاده از سمبل مجاز نیست';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.contains(RegExp(r'[ا-ی]'))) {
      return 'استفاده از حروف فارسی در رمز عبور مجاز نیست';
    }
    if (value.length < 6) {
      return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TO DO LIST',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'مون امی کدرز',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isLogin &&
                            (_showPasswordField || _showConfirmPasswordField))
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_showConfirmPasswordField) {
                                  _showConfirmPasswordField = false;
                                } else {
                                  _showPasswordField = false;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back, size: 18),
                                SizedBox(width: 5),
                                Text(
                                  'برگشت',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Row(
                            children: [
                              Text(_isLogin ? 'ورود' : 'ثبت نام'),
                              Icon(_isLogin
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (!_showPasswordField && !_isLogin)
                      Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'نام کاربری',
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.w500),
                              errorText:
                                  _validateUsername(_usernameController.text),
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  bool usernameExists =
                                      await dbHelper.checkUsernameExists(
                                          _usernameController.text);
                                  if (_validateUsername(
                                              _usernameController.text) ==
                                          null &&
                                      !usernameExists) {
                                    setState(() {
                                      _showPasswordField = true;
                                      _usernameExists = false;
                                    });
                                  } else if (usernameExists) {
                                    setState(() {
                                      _usernameExists = true;
                                    });
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.arrow_forward),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _username = value;
                                _usernameExists = false;
                              });
                            },
                          ),
                          if (_usernameExists)
                            Text(
                              'این نام کاربری قبلاً ثبت شده است',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    if (_isLogin)
                      Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'نام کاربری',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: 'رمز عبور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: _login,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _loginValid ? Colors.green : Colors.red,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    if (_showPasswordField &&
                        !_showConfirmPasswordField &&
                        !_isLogin)
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: 'رمز عبور',
                          labelStyle: TextStyle(fontWeight: FontWeight.w500),
                          errorText:
                              _validatePassword(_passwordController.text),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showConfirmPasswordField = true;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                    if (_showConfirmPasswordField && !_isLogin)
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: 'تایید رمز عبور',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_password ==
                                      _confirmPasswordController.text) {
                                    _register();
                                  } else {
                                    setState(() {
                                      _passwordsMatch = false;
                                    });
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
