import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/Settings.dart';
import 'package:todo_list/IntroNameScreen.dart';
import 'dart:math';
import 'CreateNewTask.dart';
import 'DisplayTaskList.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async{
  //not sure what this is
  WidgetsFlutterBinding.ensureInitialized();
  //open sql database/ create database if none exists
  Database database = await openDatabase(
    join(await getDatabasesPath(), 'ToDoDatabase.db'),
    onCreate: (db, version){
      return db.execute(
        'CREATE TABLE TODOS(id INTEGER, name TEXT, value INTEGER, date TEXT )'
      );
    },
    version: 1,
    onOpen:(db){
      //set x days ago as the earliest visible date on calendar scroll
      // & convert to string
      DateTime firstDate = DateTime.now().subtract(Duration(days: 3));
      String firstDateString = DateToString(firstDate);

      //clean up database when the days are not visible
      for(int i = 1; i <= 365; i++){
        firstDate = firstDate.subtract(Duration(days: 1));
        firstDateString = DateToString(firstDate);
        //print(firstDateString);
        db.delete(
          'TODOS',
          where:'date = ?',
          whereArgs:[firstDateString],
        );
      }
    },
  );

  //recall whether the app has been booted up and if the homescreen should be shown
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  //run app with that info in mind
  runApp(TODOList(database: database, showHome: showHome));
}
//convert date to a string
String DateToString(DateTime date){
  var day = 0;
  var month = 0;
  var year = 0;
  day = date.day;
  month = date.month;
  year = date.year;
  String dateString = "$day/$month/$year";
  return dateString;
}

//loading screen
class TODOList extends StatelessWidget{
  final database;
  final bool showHome;
  const TODOList({Key? key, required this.database, required this.showHome}) : super(key:key);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'TODO List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  AnimatedSplashScreen(
        splash:'assets/images/dodogif.gif',
        //decide to load home screen or the intro nickname screen
        nextScreen: showHome? MyHomePage(database: database) : IntroScreen(database: database),
      ),
      //MyHomePage(database: database,),
    );
  }
}

//home page
class MyHomePage extends StatefulWidget{
  final database;
  const MyHomePage({Key? key, required this.database}) : super(key:key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String taskName = '';
  String nickName = '';
  var taskArray = [];
  var dateString = '';
  DateTime selectedDate = DateTime.now();

  //retrieves tasks and date on startup
  void initState(){
    print("loading state");
    dateString = DateToString(selectedDate);
    retrieveTasks(DateToString(selectedDate));
  }

  //method for retrieving nickname from system.
  Future<String?> getNickName() async{
    final prefs = await SharedPreferences.getInstance();
    final String? nickname = prefs.getString('Nickname');
    if(nickname != null) {
      return nickname;
    }
  }

  //reload UI
  resetState() {
    print("setting state");
    setState(() {});
  }

  //this is where the app begins
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("DODO"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  OpenSettings(context);
                },
                child: Icon(
                Icons.settings,
                size: 26.0,
                ),
              )
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //nickname and greeting
            Align(
            alignment: Alignment.centerLeft,
              child: FutureBuilder<String?>(
                  future: getNickName(),
                  builder: (context, snapshot){
                    final curHour = DateTime.now().hour;
                    if(snapshot.hasData){
                      if(curHour < 12){
                        nickName = " Good Morning ";
                      }
                      else if(curHour >= 12 && curHour < 17 ){
                        nickName = " Good Afternoon ";
                      }
                      else if(curHour >= 17){
                        nickName = " Good Evening ";
                      }
                      nickName = nickName  +  snapshot.data!;

                      //print(nickName);
                      return Text(
                        nickName,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.oswald(
                                      textStyle: TextStyle(
                                          color: Colors.black45,
                                          letterSpacing: .5,
                                      ),
                                      fontSize: 30
                                  ),
                      );
                    }
                    else{
                      nickName = 'Nickname';
                      return Text(nickName);
                    }
                  }
              ),
            ),

            //calendar
            CalendarTimeline(
                showYears: false,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(Duration(days: 3)),
                lastDate: DateTime.now().add(Duration(days: 365)),
                onDateSelected: (date) {
                  setState(() {
                    if(date != null){
                      selectedDate = date;
                      initState();
                    }
                    else{
                      print("cannot find current date!");
                    }
                  });
                },
                leftMargin: 20,
                monthColor: Colors.teal[200],
                dayColor: Colors.teal[200],
                dayNameColor: Color(0xFF333A47),
                shrink: true,
                activeDayColor: Colors.white,
                activeBackgroundDayColor: Colors.redAccent[100],
                dotsColor: Color(0xFF333A47),
                //selectableDayPredicate: (date) => date.day != 23,
                locale: 'en',
              ),

            //display TaskList
            TaskList( taskArray: taskArray, database: widget.database,callbackFunction: initState),
          ],
        ),
      ),//new

      //add tasks button
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: (){
          setState(() {
           CreateTaskName(context).then((value){
             taskName = value;
             setState((){
               dateString = DateToString(selectedDate);
               //print(dateString);
               insertTask(TODODataSet(taskArray.length,taskName, false, dateString));
               taskArray.add(TODODataSet(taskArray.length,taskName,false, dateString));
               //print(cal.selectedDate);
             });
           });
          });
        },
      ),
    );
  }

  //pull tasks from database and adds them to the array
  Future<void> retrieveTasks(String currentSelectedDate) async{
    taskArray.length = 0;
    //selecting all from database
    List<Map> list = await widget.database.rawQuery('SELECT * FROM TODOS');
    print(list);
    for(int i = 0; i < list.length; i++){
      String name = '';
      String date = currentSelectedDate;
      bool check = false;
      int id = 0;
      list[i].entries.forEach((entry) {
        if(entry.key == 'name'){
          name = entry.value.toString();
        }
        else if(entry.key == 'value'){
          check = toBool(entry.value);
        }
        else if(entry.key =='id'){
          id = entry.value;
        }
        else if(entry.key == 'date'){
          date = entry.value;
        }
      });
      //adding them to the array
      if(name != '' && date == dateString){
        taskArray.add(TODODataSet(id,name,check,date));
        //print('First text field: $taskArray');
      }
    }
    setState(() {});
  }

  //changes a 1/0 to true/false
  bool toBool(var value){
    if(value == 1){
      return true;
    }
    else{
      return false;
    }
  }

  //insert task into database
  Future<void> insertTask(TODODataSet task) async{
    final db = await widget.database;
    final value;
    int id = Random().nextInt(4294967296);
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    Map<String, dynamic> map = {'id': id, 'name':task.name,'value':value,'date': task.date};
    await db.insert('TODOS',map,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //navigate to taskname input page
  Future<String> CreateTaskName(BuildContext context) async{
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> const TextInput()),
    );
    resetState();
    return(result);
  }

  //navigate to settings page
  Future<String> OpenSettings(BuildContext context) async{
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> const Settings()),
    );
    resetState();
    return(result);
  }
}









