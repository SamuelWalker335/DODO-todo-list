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
  void initState() {
    retrieveTasks();
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
            Calendar(),
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
               insertTask(TODODataSet(taskArray.length,taskName, false));
               taskArray.add(TODODataSet(taskArray.length,taskName,false));
               print('First text field: $taskArray');
             });
           });
          });
        },
      ),
    );
  }
  Future<void> retrieveTasks() async{
    List<Map> list = await widget.database.rawQuery('SELECT * FROM TODOS');
    print(list);
    for(int i = 0; i < list.length; i++){
      String name = '';
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
      });
      if(name != ''){
        taskArray.add(TODODataSet(id,name,check));
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
    Map<String, dynamic> map = {'id': id, 'name':task.name,'value':value};
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






