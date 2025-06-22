
import React, { useState, useEffect } from 'react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';
import { ChevronLeft, ChevronRight, Calendar, Settings, Clock, Bell, BellOff, Volume2 } from 'lucide-react';

// Mock prayer times data
const mockPrayerTimes = {
  fajr: '05:30',
  sunrise: '06:45',
  dhuhr: '12:15',
  asr: '15:30',
  maghrib: '18:45',
  isha: '20:00'
};

const prayersList = [
  { name: 'Fajr', time: '05:30', icon: '🌅' },
  { name: 'Dhuhr', time: '12:15', icon: '☀️' },
  { name: 'Asr', time: '15:30', icon: '🔆' },
  { name: 'Maghrib', time: '18:45', icon: '🌆' },
  { name: 'Isha', time: '20:00', icon: '🌙' }
];

const CircularProgress = ({ progress, size = 200, strokeWidth = 8, color = "#f97316" }: any) => {
  const radius = (size - strokeWidth) / 2;
  const circumference = Math.PI * radius; // Half circle
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <div className="relative" style={{ width: size, height: size / 2 }}>
      <svg
        className="transform rotate-180"
        width={size}
        height={size / 2}
        viewBox={`0 0 ${size} ${size / 2}`}
      >
        {/* Background arc */}
        <path
          d={`M ${strokeWidth / 2} ${size / 2} A ${radius} ${radius} 0 0 1 ${size - strokeWidth / 2} ${size / 2}`}
          fill="none"
          stroke="rgba(255,255,255,0.3)"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
        />
        {/* Progress arc */}
        <path
          d={`M ${strokeWidth / 2} ${size / 2} A ${radius} ${radius} 0 0 1 ${size - strokeWidth / 2} ${size / 2}`}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          className="transition-all duration-500 ease-in-out"
        />
      </svg>
    </div>
  );
};

const PrayerProgressWidget = () => {
  const [currentTime, setCurrentTime] = useState(new Date());
  
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  // Mock progress calculations
  const dayProgress = 65; // Mock value
  const nextPrayerProgress = 30; // Mock value
  const timeToNext = "02:15";
  const currentPrayer = "ASR";

  return (
    <div className="relative flex items-center justify-center h-48">
      {/* Outer progress circle */}
      <div className="absolute">
        <CircularProgress 
          progress={dayProgress} 
          size={280} 
          strokeWidth={8} 
          color="#f97316" 
        />
      </div>
      
      {/* Inner countdown circle */}
      <div className="absolute">
        <CircularProgress 
          progress={nextPrayerProgress} 
          size={200} 
          strokeWidth={100} 
          color="rgba(59, 130, 246, 0.3)" 
        />
      </div>
      
      {/* Center content */}
      <div className="absolute flex flex-col items-center text-white z-10">
        <p className="text-sm font-medium opacity-90">{currentPrayer}</p>
        <p className="text-xs opacity-70 mb-1">In</p>
        <p className="text-3xl font-bold mb-2">{timeToNext}</p>
        <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
          <Clock className="w-5 h-5" />
        </div>
      </div>

      {/* Prayer icons around the circle */}
      {prayersList.map((prayer, index) => {
        const angle = -Math.PI * 0.8 + (index * Math.PI * 0.4);
        const radius = 140;
        const x = radius * Math.cos(angle);
        const y = radius * Math.sin(angle) * 0.5;
        
        return (
          <div
            key={prayer.name}
            className="absolute w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center shadow-lg"
            style={{
              left: `calc(50% + ${x}px - 20px)`,
              top: `calc(50% + ${y}px - 20px)`,
            }}
          >
            <span className="text-lg">{prayer.icon}</span>
          </div>
        );
      })}
    </div>
  );
};

const DateSelector = () => {
  const [selectedDate, setSelectedDate] = useState(new Date());
  
  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', { 
      day: 'numeric', 
      month: 'long', 
      year: 'numeric' 
    });
  };

  const formatHijriDate = (date: Date) => {
    // Mock Hijri date - in real app would use hijri calendar library
    return "15 Jumada Al-Awwal, 1446 AH";
  };

  const navigateDate = (direction: number) => {
    const newDate = new Date(selectedDate);
    newDate.setDate(newDate.getDate() + direction);
    setSelectedDate(newDate);
  };

  return (
    <div className="p-4">
      <div className="flex items-center justify-between mb-4">
        <Button 
          variant="ghost" 
          size="sm"
          onClick={() => navigateDate(-1)}
        >
          <ChevronLeft className="w-5 h-5 text-teal-600" />
        </Button>
        
        <div className="text-center">
          <p className="text-lg font-bold text-gray-800">
            {formatDate(selectedDate)}
          </p>
          <p className="text-sm text-gray-600">
            {formatHijriDate(selectedDate)}
          </p>
        </div>
        
        <Button 
          variant="ghost" 
          size="sm"
          onClick={() => navigateDate(1)}
        >
          <ChevronRight className="w-5 h-5 text-teal-600" />
        </Button>
      </div>
      
      <Button 
        className="w-full bg-teal-600 hover:bg-teal-700 text-white"
        size="sm"
      >
        <Calendar className="w-4 h-4 mr-2" />
        Open Calendar
      </Button>
    </div>
  );
};

const PrayerTimesList = () => {
  const [prayedStatus, setPrayedStatus] = useState<{[key: string]: boolean}>({});
  const [alarmTypes, setAlarmTypes] = useState<{[key: string]: number}>({});

  const togglePrayerStatus = (prayerName: string) => {
    setPrayedStatus(prev => ({
      ...prev,
      [prayerName]: !prev[prayerName]
    }));
  };

  const toggleAlarmType = (prayerName: string) => {
    setAlarmTypes(prev => ({
      ...prev,
      [prayerName]: ((prev[prayerName] || 0) + 1) % 3
    }));
  };

  const getAlarmIcon = (type: number) => {
    switch (type) {
      case 1: return <Bell className="w-5 h-5" />;
      case 2: return <Volume2 className="w-5 h-5" />;
      default: return <BellOff className="w-5 h-5" />;
    }
  };

  return (
    <div className="px-4 space-y-3">
      {prayersList.map((prayer, index) => {
        const isPrayed = prayedStatus[prayer.name] || false;
        const alarmType = alarmTypes[prayer.name] || 0;
        const isCurrent = prayer.name === 'Asr'; // Mock current prayer
        
        return (
          <Card 
            key={prayer.name}
            className={`p-4 ${isCurrent ? 'bg-teal-600 text-white' : 'bg-white'}`}
          >
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <h3 className={`font-medium ${isCurrent ? 'text-white' : 'text-gray-800'}`}>
                  {prayer.name}
                </h3>
                <div className="flex items-center gap-2">
                  <span className={`text-xl font-bold ${isCurrent ? 'text-white' : 'text-gray-900'}`}>
                    {prayer.time}
                  </span>
                  <span className={`text-sm ${isCurrent ? 'text-white/70' : 'text-gray-500'}`}>
                    +10
                  </span>
                </div>
              </div>
              
              <div className="flex items-center gap-4">
                <div className="flex flex-col items-center">
                  <span className={`text-xs mb-1 ${isCurrent ? 'text-white/70' : 'text-gray-500'}`}>
                    Prayed ?
                  </span>
                  <Switch
                    checked={isPrayed}
                    onCheckedChange={() => togglePrayerStatus(prayer.name)}
                  />
                </div>
                
                <Button
                  variant="ghost"
                  size="sm"
                  className={`w-10 h-10 rounded-full ${
                    isCurrent 
                      ? 'bg-white/20 text-white hover:bg-white/30' 
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                  onClick={() => toggleAlarmType(prayer.name)}
                >
                  {getAlarmIcon(alarmType)}
                </Button>
              </div>
            </div>
          </Card>
        );
      })}
    </div>
  );
};

export default function Index() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-teal-500 to-teal-600">
      {/* Header */}
      <div className="flex justify-end p-4">
        <Button variant="ghost" size="sm" className="text-white hover:bg-white/20">
          <Settings className="w-5 h-5" />
        </Button>
      </div>

      {/* Main Content */}
      <div className="relative">
        {/* Green/Teal area with prayer progress */}
        <div className="pb-8">
          <PrayerProgressWidget />
        </div>
        
        {/* White area */}
        <div className="bg-white rounded-t-[30px] min-h-[75vh] pb-8">
          <DateSelector />
          <div className="mt-4">
            <PrayerTimesList />
          </div>
        </div>
      </div>
    </div>
  );
}
