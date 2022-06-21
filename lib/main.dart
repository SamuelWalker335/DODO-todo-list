import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Database database = await openDatabase(
    join(await getDatabasesPath(), 'ToDoDatabase.db'),
    onCreate: (db, version){
      return db.execute(
        'CREATE TABLE TODOS(name TEXT, value INTEGER)'
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
            Progress(),
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
               insertTask(TODODataSet(taskName, false));
               taskArray.add(TODODataSet(taskName,false));
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
      list[i].entries.forEach((entry) {
        if(entry.key == 'name'){
          name = entry.value.toString();
        }
        else if(entry.key == 'value'){
          check = toBool(entry.value);
        }
      });
      if(name != ''){
        taskArray.add(TODODataSet(name, check));
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
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    Map<String, dynamic> map = {'name':task.name,'value':value};
    await db.insert('TODOS',map,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTask(TODODataSet task) async{
    final db = await widget.database;
    final value;
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    Map<String, dynamic> map = {'name':task.name,'value':value};
    await db.delete(
      'TODOS',
      map,
      where:'name = ?',
      whereArgs:[task.name],
    );
  }
}


Future<String> CreateTaskName(BuildContext context) async{
  final result = await  Navigator.push(
    context,
    MaterialPageRoute(builder: (context)=> const TextInput()),
  );

  return(result);
}

//input name of TO_DO item
class TextInput extends StatefulWidget {
  const TextInput({super.key});
  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  static String nameOfTask = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'name of task',
            ),
            onChanged: (text) {
              setState(() => nameOfTask = text);
            },
          ),
          FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, nameOfTask);
            },
          ),

        ],
      ),
    );
  }
}

//progress bar
class Progress extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Text("day completed:"),
        LinearProgressIndicator(value: 0.0),
      ],
    );
  }
}

//displays items in list
class TaskList extends StatefulWidget{
  final taskArray;
  final database;
  const TaskList({Key? key, required this.taskArray, required this.database}) : super(key:key);
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 400,
    child: ListView.builder(
      //shrinkWrap: true,
      itemCount: widget.taskArray.length,
      padding: const EdgeInsets.symmetric(vertical: 50),
      itemBuilder: (BuildContext context, int index){
        return Dismissible(
          background: Container(
            color: Colors.red[300],
          ),
          key: UniqueKey(),
          onDismissed: (DismissDirection direction){
            setState((){
              deleteTask(widget.taskArray[index]);
              widget.taskArray.removeAt(index);
            });
          },
          child: TaskItem(taskArray: widget.taskArray, index: index, database: widget.database),
        );
      },
    ),
    );
  }
  Future<void> deleteTask(TODODataSet task) async{
    final db = await widget.database;
    final value;
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    await db.delete(
      'TODOS',
      where:'name = ?',
      whereArgs:[task.name],
    );
  }
}

//allows for checking items off list
class TaskItem extends StatefulWidget{
  final taskArray;
  final int index;
  final database;
  const TaskItem({Key? key, required this.taskArray, required this.index, required this.database}) : super(key:key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Checkbox(
            onChanged: (newValue) => setState((){
              widget.taskArray[widget.index].setValue = newValue;
              updateTask(widget.taskArray[widget.index]);
            }),
            value: widget.taskArray[widget.index].value,
        ),
        Text(widget.taskArray[widget.index].name),
      ],
    );
  }

  Future<void> updateTask(TODODataSet task) async{
    final db = await widget.database;
    final value;
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    Map<String, dynamic> map = {'name':task.name,'value':value};
    await db.update(
      'TODOS',
      map,
      where:'name = ?',
      whereArgs:[task.name],
    );
  }
}
class TODODataSet<String, bool> {
  String name;
  bool value;

  TODODataSet(this.name, this.value);

  set setValue(bool newValue){
    value = newValue;
  }
  set setName(String newName){
    name = newName;
  }
}

