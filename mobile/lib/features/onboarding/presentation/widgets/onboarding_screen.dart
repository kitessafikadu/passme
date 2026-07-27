import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_screen_data.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingScreenData data;

  const OnboardingScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
            ),
            child: ClipRRect(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            data.description,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 