import 'package:askyourself/screens/support_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/calendar_screen.dart';
import '../screens/manage_questions_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Text(
              "Menu",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: theme.iconTheme.color),
            title: Text(
              "Calendar",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.edit_note, color: theme.iconTheme.color),
            title: Text(
              "Manage Questions",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageQuestionsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.support, color: theme.iconTheme.color),
            title: Text(
              "Support Us",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
