import 'package:flutter/material.dart';

import 'noti.dart'; // Make sure this imports your NotiService class

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await NotiService().showNotification(
                title: "Notification Title",
                body: "This is the notification body content!",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification sent successfulllllly!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to send notification: $e')),
              );
            }
          },
          child: const Text("Send Notification"),
        ),
      ),
    );
  }
}
