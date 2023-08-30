import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Flashlate",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          // You can also set other text style properties here
        ),
      ),
      centerTitle: true, // Center the title horizontally
      backgroundColor: Colors.grey[900],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
