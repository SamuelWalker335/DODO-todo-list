import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';
import 'ProgressBar.dart';
import 'Calendar.dart';
import 'CreateNewTask.dart';
import 'DisplayTaskList.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Database database = await openDatabase(
    join(await getDatabasesPath(), 'ToDoDatabase.db'),
    onCreate: (db, version){
      return db.execute(
        'CREATE TABLE TODOS(id INTEGER, name TEXT, value INTEGER, date TEXT )'
      );
    },
    version: 1,
  );
  runApp(TODOList(database: database,));

}

class TODOList extends StatelessWidget{
  final database;
  const TODOList({Key? key, required this.database}) : super(key:key);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'TODO List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(database: database,),
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
  var taskArray = [];
  var dateString = '';
  DateTime selectedDate = DateTime.now();
  void initState() {
    dateString = DateToString(selectedDate);
    //_resetSelectedDate();
    retrieveTasks(DateToString(selectedDate));
  }
  //reset date to todays date
  void _resetSelectedDate() {
    selectedDate = DateTime.now();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("DODO Home Page"),
      ),
      body: SingleChildScrollView(
      child: Column(
          children: [
            //calendar
            CalendarTimeline(
              showYears: false,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
              onDateSelected: (date) {
                setState(() {
                  if(date != null){
                    selectedDate = date;
                    initState();
                  }
                  else{
                    print("help");
                  }
                });
              },
              leftMargin: 20,
              monthColor: Colors.teal[200],
              dayColor: Colors.teal[200],
              dayNameColor: Color(0xFF333A47),
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.redAccent[100],
              dotsColor: Color(0xFF333A47),
              selectableDayPredicate: (date) => date.day != 23,
              locale: 'en',
            ),
            //Progress(),
            TaskList( taskArray: taskArray, database: widget.database,),
            Image.asset('assets/images/dodo.png',
              height: 200,
              width: 200,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
  }
  bool toBool(var value){
    if(value == 1){
      return true;
    }
    else{
      return false;
    }
  }
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

}
Future<String> CreateTaskName(BuildContext context) async{
  final result = await  Navigator.push(
    context,
    MaterialPageRoute(builder: (context)=> const TextInput()),
  );

  return(result);
}






