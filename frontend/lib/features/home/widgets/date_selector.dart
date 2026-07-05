import 'package:flutter/material.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTap;
  const DateSelector({super.key, required this.selectedDate, required this.onTap});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;
  late List<DateTime> weekDates;
  late String monthName;

  @override
  void initState() {
    super.initState();
    weekOffset = 0;
    weekDates = generateWeekDates(weekOffset);
    monthName = DateFormat("MMMM").format(weekDates.first);
  }

  @override
  Widget build(BuildContext context) {
    weekDates = generateWeekDates(weekOffset);
    monthName = DateFormat("MMMM").format(weekDates.first);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset -= 1;

                    print('Updated Week offset --> $weekOffset');
                  });
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              Text(
                monthName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset += 1;
                    print('Updated Week offset --> $weekOffset');
                  });
                },
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SizedBox(
            height: 90,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  bool isSelected = DateFormat('dd/MM/yyyy').format(date) ==
                      DateFormat('dd/MM/yyyy').format(widget.selectedDate);

                  return GestureDetector(
                    onTap: () {
                      widget.onTap(date);
                      setState(() {
                        monthName = DateFormat('MMMM').format(date);
                        print('updated monthName is $monthName');
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 9),
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.purpleAccent.shade100 : null,
                          border: Border.all(
                            color: isSelected ? Colors.purpleAccent.shade100 : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      width: 70,
                      child: Column(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d/MM').format(date),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
