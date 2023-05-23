import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';

//displays items in list
class TaskList extends StatefulWidget{
  final taskArray;
  final database;
  final Function callbackFunction;
  const TaskList({Key? key, required this.taskArray, required this.database, required this.callbackFunction}) : super(key:key);
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: MediaQuery.of(context).size.height*.74,
      child: ListView.builder(
        //shrinkWrap: true,
        itemCount: widget.taskArray.length,
        //padding: const EdgeInsets.symmetric(vertical: 50),
        itemBuilder: (BuildContext context, int index){
          return Dismissible(
              key: UniqueKey(),
              //icons/color for dismiss right
              background: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Icon(Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ],

                ),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              ),

              //icons/color for dismiss left
              secondaryBackground: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //empty container so it stays on left
                    Container(

                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Icon(Icons.delete,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              ),

              //what to do when dismissed (right or left)
              onDismissed: (DismissDirection direction){
                //print(direction);
                //if swipe right move to next day
                if(direction == DismissDirection.startToEnd){
                  TODODataSet temp = widget.taskArray[index];

                  temp.date = incDay(temp.date);
                  widget.taskArray[index] = temp;

                  updateTask(widget.taskArray[index]);

                }
                else{
                  //if swipe left just delete task
                  setState((){
                    deleteTask(widget.taskArray[index]);
                    widget.taskArray.removeAt(index);
                  });
                }
              },

              //checklist item calls TaskItem
              child: Container(
                alignment: Alignment.center,
                //padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                height: 100,
                //color: Colors.white,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26,width:3 ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: TaskItem(taskArray: widget.taskArray, index: index, database: widget.database),
              )
          );
        },
      ),
    );
  }

  //increment a date as a string "day/month/year" by one day
  String incDay(String date){
    String day = date.substring(0, date.indexOf('/'));
    date = date.replaceRange(0, date.indexOf('/') + 1, "");
    String month = date.substring(0, date.indexOf('/'));
    date = date.replaceRange(0, date.indexOf('/') + 1, "");
    String year = date;

    DateTime newDateTime = new DateTime(int.parse(year), int.parse(month), int.parse(day) + 1);
    year = newDateTime.year.toString();
    month = newDateTime.month.toString();
    day = newDateTime.day.toString();

    String newDate = day+"/"+month+"/"+year;
    return newDate;
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
  //delete task from database
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
    //debugPrint(task.id.toString());
  }
  //update a task in the database
  Future<void> updateTask(TODODataSet task) async{
    final db = await widget.database;
    final value;
    if(task.value == true){
      value = 1;
    }
    else{
      value = 0;
    }
    Map<String, dynamic> map = {'id': task.id,'name':task.name,'value':value,'date':task.date};
    await db.update(
      'TODOS',
      map,
      where:'id = ?',
      whereArgs:[task.id],
    );
    widget.callbackFunction();
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
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
            onChanged: (newValue) => setState((){
              widget.taskArray[widget.index].setValue = newValue;
              updateTask(widget.taskArray[widget.index]);
            }),
            value: widget.taskArray[widget.index].value,
          ),
    ),
        Text(
            widget.taskArray[widget.index].name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoCondensed(
                textStyle: TextStyle(
                  color: Colors.black54,
                  letterSpacing: .5,
                ),
                fontSize: 15
            ),


        ),
      ],
    );
  }

  //update task in database
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

//datatype of todo item
class TODODataSet<int, String, bool> {
  String name;
  bool value;
  int id;
  String date;
  TODODataSet(this.id,this.name, this.value, this.date);

  set setValue(bool newValue){
    value = newValue;
  }
  set setName(String newName){
    name = newName;
  }
}