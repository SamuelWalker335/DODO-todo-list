import 'package:flutter/material.dart';
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