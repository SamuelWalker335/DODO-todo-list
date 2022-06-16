import 'package:flutter/material.dart';

void main() => runApp(TODOList());

class TODOList extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'TODO List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

//home page
class MyHomePage extends StatefulWidget{
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String taskName = '';
  var taskArray = [];
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("DODO Home Page"),
      ),
      body:Column(
        children: [
          Progress(),
          TaskList( taskArray: taskArray,),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
           CreateTaskName(context).then((value){
             taskName = value;
             setState((){
               taskArray.add(taskName);
               print('First text field: $taskArray');
             });
           });
          });
        },
      ),
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
  const TaskList({Key? key, required this.taskArray}) : super(key:key);
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        for(var i = 0; i < widget.taskArray.length; i++)
            TaskItem(label: widget.taskArray[i],)
      ],
    );
  }
}

//allows for checking items off list
class TaskItem extends StatefulWidget{
  final String label;
  const TaskItem({Key? key, required this.label}) : super(key:key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool? _value = false;
  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Checkbox(
            onChanged: (newValue) => setState(() => _value = newValue),
            value: _value,
        ),
        Text(widget.label),
      ],
    );
  }
}

