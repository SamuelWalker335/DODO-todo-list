/*
import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:todo_list/main.dart';
class Calendar extends StatefulWidget{
  DateTime selectedDate = DateTime.now();
  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
  }

  void _resetSelectedDate() {
    widget.selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        CalendarTimeline(
          showYears: false,
          initialDate: widget.selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
          onDateSelected: (date) {
            setState(() {
              if(date != null){
                widget.selectedDate = date;
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
      ],
    );
  }
  Future<String> retrieveDate() async{
    var day = 0;
    var month = 0;
    var year = 0;
    if(widget.selectedDate != null){
      day = widget.selectedDate.day;
      month = widget.selectedDate.month;
      year = widget.selectedDate.year;
    }
    String date = "$day/$month/$year";
    return date;
  }
}
 */