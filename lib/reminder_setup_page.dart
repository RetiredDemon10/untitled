import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ReminderSetupPage extends StatefulWidget {
  const ReminderSetupPage({super.key});

  @override
  _ReminderSetupPageState createState() => _ReminderSetupPageState();
}

class _ReminderSetupPageState extends State<ReminderSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reminderNameController = TextEditingController();
  final TextEditingController notificationNameController =
      TextEditingController();
  String? _selectedNotificationSound;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle notification tapped logic here
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> saveReminder() async {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      DateTime scheduledDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Ensure the scheduled time is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a future date and time.')),
        );
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('reminders').add({
        'name': reminderNameController.text,
        'notificationName': notificationNameController.text,
        'scheduledDate': scheduledDate,
        'sound': _selectedNotificationSound,
      });

      // Schedule the notification
      await _scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: reminderNameController.text,
        body: notificationNameController.text,
        scheduledDate: scheduledDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Reminder set for ${DateFormat('yyyy-MM-dd HH:mm').format(scheduledDate)}'),
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear the form fields after saving
      reminderNameController.clear();
      notificationNameController.clear();
      setState(() {
        _selectedNotificationSound = null;
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      });
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Setup Your Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: reminderNameController,
                decoration:
                    const InputDecoration(labelText: 'Health Reminder Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reminder name.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: notificationNameController,
                decoration:
                    const InputDecoration(labelText: 'Notification Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a notification name.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedNotificationSound,
                decoration:
                    const InputDecoration(labelText: 'Notification Sound'),
                items: ['Default', 'Chime', 'Alert', 'Ringtone']
                    .map((sound) => DropdownMenuItem(
                          value: sound,
                          child: Text(sound),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedNotificationSound = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a notification sound.';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text("Time: ${_selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveReminder,
                child: const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
