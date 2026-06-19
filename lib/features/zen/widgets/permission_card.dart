import 'package:flutter/material.dart';

/**
 * A minimalistic card representing a system defense protocol.
 * Focuses on transparency and subtle visual feedback.
 */
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onGrant;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isGranted ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted ? Colors.cyanAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isGranted ? Colors.cyanAccent.withOpacity(0.6) : Colors.white24,
            size: 20
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isGranted ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    letterSpacing: 0.5
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 10,
                    fontWeight: FontWeight.w200
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (isGranted) {
      return Icon(
        Icons.check_rounded,
        color: Colors.cyanAccent.withOpacity(0.4),
        size: 18
      );
    }

    return InkWell(
      onTap: onGrant,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "ACTIVATE",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1
          )
        ),
      ),
    );
  }
}
