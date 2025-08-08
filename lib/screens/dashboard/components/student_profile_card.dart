import 'package:flutter/material.dart';

class StudentProfileCard extends StatelessWidget {
  final String nombreCompleto;
  final String grado;
  final String? avatarUrl;

  const StudentProfileCard({
    Key? key,
    required this.nombreCompleto,
    required this.grado,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  nombreCompleto.isNotEmpty ? nombreCompleto[0] : '',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreCompleto,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              grado,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    ));
  }
} 