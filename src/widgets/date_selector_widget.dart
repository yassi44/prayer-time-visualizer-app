
import 'package:flutter/material.dart';
import 'package:hijri/hijri.dart';
import 'package:intl/intl.dart';

class DateSelectorWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.fromDate(widget.selectedDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  widget.onDateChanged(widget.selectedDate.subtract(const Duration(days: 1)));
                },
                icon: const Icon(Icons.chevron_left, color: Colors.teal),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('d MMMM, yyyy').format(widget.selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hijriDate.hDay} ${hijriDate.longMonthName}, ${hijriDate.hYear} AH',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onDateChanged(widget.selectedDate.add(const Duration(days: 1)));
                },
                icon: const Icon(Icons.chevron_right, color: Colors.teal),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Open Calendar button
          ElevatedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                widget.onDateChanged(date);
              }
            },
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            label: const Text(
              'Open Calendar',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Week view
          _buildWeekView(),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = date.day == widget.selectedDate.day &&
            date.month == widget.selectedDate.month &&
            date.year == widget.selectedDate.year;
        final isToday = date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;
        
        return GestureDetector(
          onTap: () => widget.onDateChanged(date),
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.teal, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).substring(0, 3),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
