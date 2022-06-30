import 'package:flutter/material.dart';

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
      where:'id = ?',
      whereArgs:[task.id],
    );
    debugPrint(task.id.toString());
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
    Map<String, dynamic> map = {'id': task.id,'name':task.name,'value':value};
    await db.update(
      'TODOS',
      map,
      where:'id = ?',
      whereArgs:[task.id],
    );
  }
}

class TODODataSet<int,String, bool> {
  String name;
  bool value;
  int id;
  TODODataSet(this.id,this.name, this.value);

  set setValue(bool newValue){
    value = newValue;
  }
  set setName(String newName){
    name = newName;
  }
}