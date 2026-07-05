import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommonEmptyState extends StatelessWidget {
  const CommonEmptyState({super.key, required this.dateTime});
  final DateTime dateTime;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_data.png',
            fit: BoxFit.fill,
          ),
          Text('No Tasks For ${DateFormat('dd/MM/yyyy').format(dateTime)} is available'),
        ],
      ),
    );
  }
}
