import 'package:flutter/material.dart';
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
        title: const Text('Create Task'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Task Name',
            ),
            onChanged: (text) {
              setState(() => nameOfTask = text);
            },
            onSubmitted: (text){
              Navigator.pop(context, nameOfTask);
            },
          ),
          FloatingActionButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.pop(context, nameOfTask);
            },
          ),

        ],
      ),
    );
  }
}