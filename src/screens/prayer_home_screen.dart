
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prayer_times_provider.dart';
import '../widgets/prayer_progress_widget.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/prayer_times_list_widget.dart';

class PrayerHomeScreen extends ConsumerStatefulWidget {
  const PrayerHomeScreen({super.key});

  @override
  ConsumerState<PrayerHomeScreen> createState() => _PrayerHomeScreenState();
}

class _PrayerHomeScreenState extends ConsumerState<PrayerHomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider(selectedDate));

    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final whiteContainerHeight = constraints.maxHeight * 0.75;

          return Stack(
            children: [
              // Green/Teal area with prayer progress
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: constraints.maxHeight - whiteContainerHeight,
                child: Container(
                  decoration: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF26A69A),
                      Color(0xFF4DB6AC),
                    ],
                  ).createShader(Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight - whiteContainerHeight)) != null
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF26A69A),
                              Color(0xFF4DB6AC),
                            ],
                          ),
                        )
                      : const BoxDecoration(color: Color(0xFF26A69A)),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: PrayerProgressWidget(),
                    ),
                  ),
                ),
              ),
              
              // White area
              Positioned(
                top: constraints.maxHeight - whiteContainerHeight,
                left: 0,
                right: 0,
                height: whiteContainerHeight,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Date selector
                        DateSelectorWidget(
                          selectedDate: selectedDate,
                          onDateChanged: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Prayer times list
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: prayerTimesAsync.when(
                            data: (prayerTimes) => PrayerTimesListWidget(
                              prayerTimes: prayerTimes,
                              selectedDate: selectedDate,
                            ),
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'Error loading prayer times: $error',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
