
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_time_model.dart';
import '../services/location_service.dart';

final prayerTimesProvider = FutureProvider.family<PrayerTimeModel, DateTime>((ref, date) async {
  final position = await ref.read(locationServiceProvider).getCurrentLocation();
  final coordinates = Coordinates(position.latitude, position.longitude);
  final params = CalculationMethod.karachi.getParameters();
  params.madhab = Madhab.hanafi;
  
  final dateComponents = DateComponents.from(date);
  final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
  
  return PrayerTimeModel.fromPrayerTimes(prayerTimes);
});

final currentPrayerProvider = Provider<Prayer?>((ref) {
  final now = DateTime.now();
  final prayerTimesAsync = ref.watch(prayerTimesProvider(now));
  
  return prayerTimesAsync.when(
    data: (prayerTimes) {
      final position = ref.read(locationServiceProvider).getCurrentPosition();
      if (position == null) return null;
      
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;
      
      final dateComponents = DateComponents.from(now);
      final adhanPrayerTimes = PrayerTimes(coordinates, dateComponents, params);
      
      return adhanPrayerTimes.currentPrayer();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final nextPrayerProvider = Provider<Prayer?>((ref) {
  final now = DateTime.now();
  final prayerTimesAsync = ref.watch(prayerTimesProvider(now));
  
  return prayerTimesAsync.when(
    data: (prayerTimes) {
      final position = ref.read(locationServiceProvider).getCurrentPosition();
      if (position == null) return null;
      
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;
      
      final dateComponents = DateComponents.from(now);
      final adhanPrayerTimes = PrayerTimes(coordinates, dateComponents, params);
      
      return adhanPrayerTimes.nextPrayer();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
