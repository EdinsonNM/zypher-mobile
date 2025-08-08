import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  final int itemCount;
  final List<Map<String, String>>? activities;

  const ActivityList({
    super.key,
    this.itemCount = 5,
    this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities?.length ?? itemCount,
      itemBuilder: (context, index) {
        final activity = activities != null && activities!.length > index
            ? activities![index]
            : null;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.assignment,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(activity?['title'] ?? 'Tarea de Matemáticas'),
            subtitle: Text(activity?['subtitle'] ?? 'Fecha de entrega: 15/03/2024'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
} 