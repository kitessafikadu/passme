import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Language { english, amharic }

class DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final Function() onTap;
  final Language selectedLanguage;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
    required this.selectedLanguage,
  });

  String get formattedDate {
    if (selectedDate == null) {
      return selectedLanguage == Language.english ? "Select Date" : "ቀን ይምረጡ";
    }
    return DateFormat('EEEE, MMMM d, y').format(selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
