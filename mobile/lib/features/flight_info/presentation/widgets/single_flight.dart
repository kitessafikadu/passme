import 'package:flutter/material.dart';
import '../../domain/entities/flight.dart';

class SingleFlight extends StatelessWidget {
  final Flight flight;
  final VoidCallback onDelete;
  final bool isDeleting;

  const SingleFlight({
    super.key,
    required this.flight,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ListTile(
            enabled: !isDeleting,
            leading: Icon(Icons.message, color: Colors.white, size: 42),
            title: Text(
              flight.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(flight.fromCountry,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    const Icon(Icons.flight_land,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(flight.toCountry,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${flight.date.day}/${flight.date.month}/${flight.date.year}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.work_outline,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ],
            ),
            trailing: isDeleting
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 30,
              ),
              onPressed: onDelete,
            ),
            onTap: isDeleting
                ? null
                : () {
              Navigator.pushNamed(
                context,
                '/flights/detail',
                arguments: flight,
              );
            },
          ),
        ],
      ),
    );
  }
}