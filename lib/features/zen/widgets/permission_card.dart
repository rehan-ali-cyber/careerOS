import 'package:flutter/material.dart';
import '../../../core/widgets/neomorphic/neumorphic_container.dart';

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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicContainer(
        borderRadius: 20,
        depth: isGranted ? 2 : 8,
        isPressed: isGranted,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              NeumorphicContainer(
                shape: BoxShape.circle,
                depth: isGranted ? 1 : 4,
                isPressed: isGranted,
                baseColor: isGranted ? theme.colorScheme.primary.withOpacity(0.1) : theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: isGranted ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.24),
                  size: 20
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isGranted ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.5
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.38),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    if (isGranted) {
      return Icon(
        Icons.check_circle_rounded,
        color: theme.colorScheme.primary,
        size: 20
      );
    }

    return NeumorphicContainer(
      borderRadius: 12,
      depth: 2,
      baseColor: theme.colorScheme.primary.withOpacity(0.1),
      child: InkWell(
        onTap: onGrant,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            "ACTIVATE",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1
            )
          ),
        ),
      ),
    );
  }
}
