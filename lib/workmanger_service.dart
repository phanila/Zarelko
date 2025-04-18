import 'package:logger/logger.dart';
import 'package:powersync/powersync.dart';
import 'package:workmanager/workmanager.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'database/database.dart';
import 'database/powersync.dart';
import 'database/schema.dart';
import 'notifications_service.dart';

Future<void> backgroundTask() async {
  print("start");
  tz.initializeTimeZones();
  await NotificationsService.init(isForeground: false);
  print("Notificatioon initialized");
  //NotificationsService().showInstantNotification('Test notification', 'from workmanager');

  // Fetch items expiring today from the Drift database
  db = PowerSyncDatabase(
      schema: schema, path: await getDatabasePath(), logger: attachedLogger);
  await db.initialize();
  // Initialize the Drift database
  var appDB = AppDatabase(db);
  print("Database initialized");

  final expiringItems = await appDB.getExpiringToday();
  final expiringWeek = await appDB.getExpiringInWeek();
  String content = "Today:\n";
  // Send notifications for each expiring item
  for (var item in expiringItems) {
    content += "-${item.name} ${item.desc}\n";
  }
  content += "In week:\n";
  // Send notifications for each expiring item
  for (var item in expiringWeek) {
    content += "-${item.name} ${item.desc}\n";
  }
  NotificationsService().showInstantNotification('Expiring', content);
}

void initializeWorkManager() {
  tz.initializeTimeZones();
  Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
  );
  // Schedule the task for 9 AM every day
  scheduleDailyTaskAt9AM();
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  print("task in workmanager");
  Workmanager().executeTask((task, inputData) async {
    try{
      if (task == 'daily_expiry_check') {
        print("HHH");
        await backgroundTask();
      }
    } catch(err) {
      Logger().e(err.toString()); // Logger flutter package, prints error on the debug console
      throw Exception(err);
    }
    return Future.value(true);
  });
}

void scheduleDailyTaskAt9AM() {
  final now = DateTime.now(); // Get current local time

  // Target time in local timezone (8:30 AM today)
  final targetTime = DateTime(now.year, now.month, now.day, 8, 30, 0); // 8:30 AM today

  // If the target time has already passed today, schedule for tomorrow
  DateTime adjustedTargetTime = targetTime;
  if (now.isAfter(targetTime)) {
    adjustedTargetTime = targetTime.add(Duration(days: 1)); // Schedule for tomorrow
  }

  // Calculate the delay by subtracting current time from the adjusted target time
  final delay = adjustedTargetTime.isBefore(now)
      ? adjustedTargetTime.add(Duration(days: 1)).difference(now)
      : adjustedTargetTime.difference(now);
  // Register the periodic task to execute every day at 9 AM
  Workmanager().registerPeriodicTask(
    '1', // Task ID
    'daily_expiry_check', // Task name
    frequency: Duration(days: 1), // Repeats every day
    initialDelay: delay
    );
  print(delay);
  print("Task registered to run daily at 9 AM");
}