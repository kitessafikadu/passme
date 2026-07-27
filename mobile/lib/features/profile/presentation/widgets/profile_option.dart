import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileOption extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final VoidCallback onTap;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const ProfileOption({
    super.key,
    required this.title,
    required this.onTap,
    required this.leadingIcon,
    this.trailingIcon,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                title,
                style: titleStyle ??
                    GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingIcon != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: trailingIcon,
              ),
          ],
        ),
      ),
    );
  }
}
