import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationsEnabled = true;
  String _language = 'فارسی';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تنظیمات'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('فعال/غیرفعال کردن اعلان‌ها'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('زبان'),
              subtitle: Text(_language),
              onTap: () {
                _showLanguageDialog();
              },
            ),
            Divider(),
            ListTile(
              title: Text('خروج از حساب کاربری'),
              textColor: Colors.red,
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('انتخاب زبان'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('فارسی'),
                onTap: () {
                  setState(() {
                    _language = 'فارسی';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('انگلیسی'),
                onTap: () {
                  setState(() {
                    _language = 'انگلیسی';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {}
}
