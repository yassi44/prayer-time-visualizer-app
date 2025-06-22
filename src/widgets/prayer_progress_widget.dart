
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/prayer_times_provider.dart';
import '../models/prayer_time_model.dart';
import 'package:adhan/adhan.dart';

class PrayerProgressWidget extends ConsumerStatefulWidget {
  const PrayerProgressWidget({super.key});

  @override
  ConsumerState<PrayerProgressWidget> createState() => _PrayerProgressWidgetState();
}

class _PrayerProgressWidgetState extends ConsumerState<PrayerProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider(DateTime.now()));
    final currentPrayer = ref.watch(currentPrayerProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);

    return prayerTimesAsync.when(
      data: (prayerTimes) {
        final now = DateTime.now();
        final progress = _calculateDayProgress(prayerTimes, now);
        final timeToNext = _calculateTimeToNext(prayerTimes, now, nextPrayer);

        return Container(
          height: 200,
          width: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer progress circle
              CustomPaint(
                size: const Size(280, 140),
                painter: OuterProgressPainter(
                  progress: progress,
                  prayerTimes: prayerTimes,
                ),
              ),
              // Inner countdown circle
              CustomPaint(
                size: const Size(200, 100),
                painter: InnerCountdownPainter(
                  progress: timeToNext.progress,
                ),
              ),
              // Center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentPrayer?.name.toUpperCase() ?? 'ASR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'In',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeToNext.timeString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Clock icon
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              // Prayer icons around the circle
              ..._buildPrayerIcons(prayerTimes),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  List<Widget> _buildPrayerIcons(PrayerTimeModel prayerTimes) {
    final prayers = [
      {'name': 'Fajr', 'icon': '🌅', 'angle': -math.pi * 0.8},
      {'name': 'Duhr', 'icon': '☀️', 'angle': -math.pi * 0.4},
      {'name': 'Asr', 'icon': '🔆', 'angle': 0.0},
      {'name': 'Maghrib', 'icon': '🌆', 'angle': math.pi * 0.4},
      {'name': 'Isha', 'icon': '🌙', 'angle': math.pi * 0.8},
    ];

    return prayers.map((prayer) {
      final angle = prayer['angle'] as double;
      final radius = 150.0;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle) * 0.5; // Flatten for semi-circle

      return Positioned(
        left: 150 + x - 20,
        top: 100 + y - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              prayer['icon'] as String,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    }).toList();
  }

  double _calculateDayProgress(PrayerTimeModel prayerTimes, DateTime now) {
    final prayers = prayerTimes.prayersList;
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    
    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].time)) {
        if (i == 0) return 0.0;
        final prevTime = i > 0 ? prayers[i - 1].time : dayStart;
        final totalDuration = prayers[i].time.difference(prevTime).inMinutes;
        final elapsed = now.difference(prevTime).inMinutes;
        return (i - 1 + elapsed / totalDuration) / prayers.length;
      }
    }
    return 1.0;
  }

  TimeToNext _calculateTimeToNext(PrayerTimeModel prayerTimes, DateTime now, Prayer? nextPrayer) {
    if (nextPrayer == null) return TimeToNext(progress: 0.0, timeString: '00:00');
    
    final prayers = prayerTimes.prayersList;
    final nextPrayerTime = prayers.firstWhere((p) => p.prayer == nextPrayer).time;
    
    final difference = nextPrayerTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    final timeString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    
    // Calculate progress for inner circle (assuming max 6 hours between prayers)
    final maxMinutes = 360; // 6 hours
    final remainingMinutes = difference.inMinutes;
    final progress = 1.0 - (remainingMinutes / maxMinutes).clamp(0.0, 1.0);
    
    return TimeToNext(progress: progress, timeString: timeString);
  }
}

class TimeToNext {
  final double progress;
  final String timeString;
  
  TimeToNext({required this.progress, required this.timeString});
}

class OuterProgressPainter extends CustomPainter {
  final double progress;
  final PrayerTimeModel prayerTimes;

  OuterProgressPainter({required this.progress, required this.prayerTimes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class InnerCountdownPainter extends CustomPainter {
  final double progress;

  InnerCountdownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 5;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi,
      math.pi,
      true,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.teal.shade400
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      math.pi,
      math.pi * progress,
      true,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
