
import 'package:adhan/adhan.dart';

class PrayerTimeModel {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimeModel.fromPrayerTimes(PrayerTimes prayerTimes) {
    return PrayerTimeModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
    );
  }

  List<PrayerTimeItem> get prayersList => [
    PrayerTimeItem(name: 'Fajr', time: fajr, prayer: Prayer.fajr),
    PrayerTimeItem(name: 'Duhr', time: dhuhr, prayer: Prayer.dhuhr),
    PrayerTimeItem(name: 'Asr', time: asr, prayer: Prayer.asr),
    PrayerTimeItem(name: 'Maghrib', time: maghrib, prayer: Prayer.maghrib),
    PrayerTimeItem(name: 'Isha', time: isha, prayer: Prayer.isha),
  ];
}

class PrayerTimeItem {
  final String name;
  final DateTime time;
  final Prayer prayer;

  PrayerTimeItem({
    required this.name,
    required this.time,
    required this.prayer,
  });
}

enum AlarmType {
  none,
  defaultAlarm,
  adhan,
}
