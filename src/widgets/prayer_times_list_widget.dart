
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';
import '../services/prayer_tracker_service.dart';

class PrayerTimesListWidget extends ConsumerStatefulWidget {
  final PrayerTimeModel prayerTimes;
  final DateTime selectedDate;

  const PrayerTimesListWidget({
    super.key,
    required this.prayerTimes,
    required this.selectedDate,
  });

  @override
  ConsumerState<PrayerTimesListWidget> createState() => _PrayerTimesListWidgetState();
}

class _PrayerTimesListWidgetState extends ConsumerState<PrayerTimesListWidget> {
  Map<String, bool> prayedStatus = {};
  Map<String, AlarmType> alarmTypes = {};

  @override
  void initState() {
    super.initState();
    _loadPrayerStatus();
    _loadAlarmSettings();
  }

  Future<void> _loadPrayerStatus() async {
    final trackerService = ref.read(prayerTrackerServiceProvider);
    for (final prayer in widget.prayerTimes.prayersList) {
      final prayed = await trackerService.isPrayerLogged(widget.selectedDate, prayer.prayer);
      setState(() {
        prayedStatus[prayer.name] = prayed;
      });
    }
  }

  Future<void> _loadAlarmSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (final prayer in widget.prayerTimes.prayersList) {
      final alarmIndex = prefs.getInt('alarm_${prayer.name}') ?? 0;
      setState(() {
        alarmTypes[prayer.name] = AlarmType.values[alarmIndex];
      });
    }
  }

  Future<void> _togglePrayerStatus(String prayerName, bool value) async {
    final trackerService = ref.read(prayerTrackerServiceProvider);
    final prayer = widget.prayerTimes.prayersList.firstWhere((p) => p.name == prayerName);
    
    await trackerService.logPrayer(widget.selectedDate, prayer.prayer, value);
    setState(() {
      prayedStatus[prayerName] = value;
    });
  }

  Future<void> _toggleAlarmType(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final currentType = alarmTypes[prayerName] ?? AlarmType.none;
    
    AlarmType newType;
    switch (currentType) {
      case AlarmType.none:
        newType = AlarmType.defaultAlarm;
        break;
      case AlarmType.defaultAlarm:
        newType = AlarmType.adhan;
        break;
      case AlarmType.adhan:
        newType = AlarmType.none;
        break;
    }
    
    await prefs.setInt('alarm_$prayerName', newType.index);
    setState(() {
      alarmTypes[prayerName] = newType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.prayerTimes.prayersList.map((prayer) {
        final isPrayed = prayedStatus[prayer.name] ?? false;
        final alarmType = alarmTypes[prayer.name] ?? AlarmType.none;
        final isCurrentPrayer = prayer.name == 'Asr'; // This should be dynamic based on current time
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentPrayer ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Prayer name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isCurrentPrayer ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(prayer.time),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isCurrentPrayer ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+10',
                          style: TextStyle(
                            fontSize: 14,
                            color: isCurrentPrayer ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Controls
              Row(
                children: [
                  // Prayed toggle
                  Column(
                    children: [
                      Text(
                        'Prayed ?',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentPrayer ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Switch(
                        value: isPrayed,
                        onChanged: (value) => _togglePrayerStatus(prayer.name, value),
                        activeColor: isCurrentPrayer ? Colors.white : Colors.teal,
                        activeTrackColor: isCurrentPrayer ? Colors.white.withOpacity(0.3) : Colors.teal.withOpacity(0.3),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Alarm button
                  GestureDetector(
                    onTap: () => _toggleAlarmType(prayer.name),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrentPrayer ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getAlarmIcon(alarmType),
                        color: isCurrentPrayer ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getAlarmIcon(AlarmType alarmType) {
    switch (alarmType) {
      case AlarmType.none:
        return Icons.notifications_off;
      case AlarmType.defaultAlarm:
        return Icons.notifications;
      case AlarmType.adhan:
        return Icons.volume_up;
    }
  }
}
