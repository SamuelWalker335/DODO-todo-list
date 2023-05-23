import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//input name of TO_DO item
class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            setState(() {});
            },
          child: Icon(
          Icons.arrow_back,  // add custom icons also
          ),
        ),
      ),
      body: Column(
        children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nickname',
              ),
              onSubmitted: (value){
                SubmitName(value);
              },
            ),
        ],
      ),
    );
  }
  void SubmitName(String value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Nickname', value);

    final String? savedVal = prefs.getString('Nickname');
    if(savedVal != null)
      print('submitted nickname: ' + savedVal);
  }
}