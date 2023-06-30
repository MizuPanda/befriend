import 'package:flutter/material.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isNotificationOn ? Icons.notifications : Icons.notifications_off,
        size: 30,
      ),
      onPressed: () {
        setState(() {
          _isNotificationOn = !_isNotificationOn;
        });
      },
    );
  }
}
