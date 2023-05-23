import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/main.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class IntroScreen extends StatefulWidget{
  final database;
  const IntroScreen({Key? key, required this.database}) : super(key:key);
  @override
  State<IntroScreen> createState() => IntroScreenState();
}
class IntroScreenState extends State<IntroScreen>{
  String nickName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.,
        children: [
          Image.asset(
            'assets/images/dodogif.gif',
            height:150,
            width: 150,
          ),
          Text(
            'What should we call you?',
            textAlign: TextAlign.center,
          ),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Enter your name/nickname',

            ),
            onChanged: (value){
              nickName = value;
            },
            onSubmitted: (value){
              nickName = value;
              SubmitName(value);
              goHome(context, widget.database, true);
            },
          ),
          ElevatedButton(
            child: const Text('Confirm') ,
              onPressed: () {
                print("pressed!");
                SubmitName(nickName);
                goHome(context, widget.database, true);
              }
          ),
        ],
      ),
    );
  }
  void SubmitName(String value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Nickname', value);
    await prefs.setBool('showHome', true);

    final String? savedVal = prefs.getString('Nickname');
    if(savedVal != null)
      print('submitted nickname: ' + savedVal);
  }


  void goHome(BuildContext context, Database database, bool showHome){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TODOList(database: database, showHome: showHome)),
    );
  }

}
