import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileOption extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final VoidCallback onTap;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const ProfileOption({super.key, required this.title, required this.onTap, required this.leadingIcon, this.trailingIcon, this.titleStyle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(title, style: titleStyle ?? GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
      trailing: trailingIcon,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
