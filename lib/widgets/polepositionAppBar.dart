
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PolePositionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const PolePositionAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          tooltip: 'Navigation',
          onSelected: (value) {
            context.go(value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: '/',
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text('Accueil'),
              ),
            ),
            PopupMenuItem(
              value: '/drivers-standings',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Classement pilotes'),
              ),
            ),
            PopupMenuItem(
              value: '/constructors-standings',
              child: ListTile(
                leading: Icon(Icons.groups),
                title: Text('Classement constructeurs'),
              ),
            ),
            PopupMenuItem(
              value: '/races',
              child: ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Calendrier'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
