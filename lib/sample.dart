import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // For Timer
import 'dart:convert'; // For JSON decoding
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For notifications
import 'navbar.dart';
import 'footer.dart';
import 'main.dart';

// Define the AnotherWidget StatefulWidget
class AnotherWidget extends StatefulWidget {
  @override
  _AnotherWidgetState createState() => _AnotherWidgetState();
}

// State management for the widget
class _AnotherWidgetState extends State<AnotherWidget> {
  final String authToken = '38UvYMieBFntyk2UOTALZWfFN4rsuiig'; // Your Blynk Auth Token
  bool? isOnline; // Nullable to indicate unknown state
  bool? seedCounterState; // True for on, False for off, null for unknown
  int seedCount = 0; // To track the seed count
  Timer? seedCheckTimer; // Timer for checking seed count
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Notification plugin

  List<String> notificationMessages = []; // List to store notifications
  Timer? notificationTimer; // Timer to generate notifications every 2 seconds

  @override
  void initState() {
    super.initState();

    // Initialize notifications
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Default app icon
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Check initial device status
    isDeviceOnline().then((status) {
      setState(() {
        isOnline = status;
      });
    });

    // Check initial Seed Counter state
    getSeedCounterState().then((state) {
      setState(() {
        seedCounterState = state;
      });
      if (state == true) {
        startSeedCounterTimer(); // Start the timer if the Seed Counter is on
      }
    });
  }
  Future<bool> isDeviceOnline() async {
  final response = await http.get(
    Uri.parse('http://blynk.cloud/external/api/isHardwareConnected?token=$authToken'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as bool; // Convert response to boolean
  } else {
    throw Exception('Failed to fetch device status'); // Handle non-200 status
  }
}

  Future<bool?> getSeedCounterState() async {
    try {
      // Assume V1 represents the Seed Counter state
      final response = await http.get(
        Uri.parse(
          'http://blynk.cloud/external/api/get?token=$authToken&v1'
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is String) {
          return responseBody == "1"; // Convert to boolean
        } else {
          return null; // Unexpected response type
        }
      } else {
        print('Error: ${response.statusCode}'); // Log status code
        return null; // Return null if not successful
      }
    } catch (e) {
      print('Exception caught: $e'); // Log the exception
      return null; // Return null if an exception occurs
    }
  }

  Future<int> getSeedCount() async {
  // Sending the GET request
  final response = await http.get(
    Uri.parse('http://blynk.cloud/external/api/get?token=$authToken&v0'),
  );

  if (response.statusCode == 200) {
    // Convert the response body to an integer
    try {
      // Check if the response body is an integer
      int seedCount = int.parse(response.body.trim()); // Safe conversion to int
      return seedCount;
    } catch (e) {
      throw Exception("Response body could not be converted to an int: ${response.body}");
    }
  } else {
    throw Exception('Failed to fetch Seed Count');
  }
}

  Future<void> toggleSeedCounter() async {
    if (seedCounterState == null) return; // If state is unknown, do nothing

    // New state is the opposite of the current state
    final newState = !seedCounterState!;
    final response = await http.get(
      Uri.parse(
        'http://blynk.cloud/external/api/update?token=$authToken&v1=${newState ? 1 : 0}'
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        print(newState);
        seedCounterState = newState; // Update the local state
      });
      if (newState == true) {
        print(1);
        startSeedCounterTimer(); // Start the timer when turned on
      } else {
        stopSeedCounterTimer(); // Stop the timer when turned off
      }
    } else {
      throw Exception('Failed to toggle Seed Counter');
    }
  }

  void startSeedCounterTimer() {
    if(seedCounterState==true)
    {
    if (seedCheckTimer != null) {
      seedCheckTimer!.cancel(); // Ensure any previous timer is canceled
    }

    int lastSeedCount = seedCount; // Store the last seed count
    int pp=0;
    seedCheckTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      int currentSeedCount = await getSeedCount(); // Get the current seed count
      setState(() {
        seedCount = currentSeedCount; // Update the seed count
      });

      if (currentSeedCount == lastSeedCount && pp<20) {
        // If seed count has not increased for 3 seconds
        Timer(Duration(milliseconds: 2000), () {
          if (currentSeedCount == lastSeedCount && pp<20) {
            String message = 'Warning: Seed count not increasing!';
            print("warning");
            pp+=2;
            showNotification(message); // Generate notification
            notificationMessages.add(message); // Store the notification message
          }
        });
      } else if(currentSeedCount!=lastSeedCount && pp<20){
        print(lastSeedCount);
        pp=0;
        lastSeedCount = currentSeedCount; // Update the last seed count
      }

      // If seed count does not increase for 10 seconds, turn off Seed Counter
      if (pp >= 20 && currentSeedCount == lastSeedCount) {
        print("switch off");
        await toggleSeedCounter();
        print(seedCounterState); // Turn off Seed Counter
        timer.cancel();
         // Stop the timer
      }
    });
    }
  }

  void stopSeedCounterTimer() {
    if (seedCheckTimer != null) {
      seedCheckTimer!.cancel(); // Stop the timer when not needed
    }
  }

  void showNotification(String message) {
    var androidDetails = AndroidNotificationDetails(
      'channelId', // Channel ID
      'Seed Count Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformDetails = NotificationDetails(
      android: androidDetails,
    );

    flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Seed Counter Alert', // Notification title
      message, // Notification message
      platformDetails,
    );
  }

  void showNotificationsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: SingleChildScrollView(
            child: ListBody(
              children: notificationMessages.map((message) => Text(message)).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (seedCheckTimer != null) {
      seedCheckTimer!.cancel(); // Stop the timer when the widget is disposed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Row(
          children: [
            Expanded(
              child: NavBar(
                searchController: TextEditingController(),
                onSearchImage: (imageUrl) {
                  // Implement search behavior if needed
                },
                onSmartSeederIconPressed: () {
                  // Implement specific behavior for smart seeder icon if needed
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                if (seedCounterState == true) {
                  showNotificationsList(context); // Show list of notifications
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seed Counter is not running')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                isOnline == null
                  ? 'Checking device status...'
                  : (isOnline!
                    ? 'The device is ready to work'
                    : 'The device is offline'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isOnline == true // Enable only if the device is online
                ? () async {
                    await toggleSeedCounter();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          seedCounterState! 
                            ? 'Seed Counter turned off' 
                            : 'Seed Counter turned on'
                        ),
                      ),
                    );
                  }
                : null, // Disable if offline
              child: Text(
                seedCounterState == null 
                  ? 'Loading...' 
                  : (seedCounterState! ? 'Seed Counter Off' : 'Seed Counter On'),
              ),
            ),
          ),
          // Display the seed count if Seed Counter is on
          if (seedCounterState == true) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Current Seed Count: $seedCount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (isOnline != true) // Only show the footer when the device is offline
            Footer(
              onBackButtonPressed: () {
                Navigator.pop(context); // Allow navigating back
              },
              onHomePageButtonPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CropImageSearch()), // Home page reference
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
