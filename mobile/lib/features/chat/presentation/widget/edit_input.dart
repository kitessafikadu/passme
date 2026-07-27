import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/presentation/widget/answer_bubble.dart';

class EditInput extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onSend;
  final Map<String, dynamic> question;

  const EditInput({
    super.key,
    required this.initialValue,
    required this.onSend,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              "Answer:",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 2),
            child: Text(
              question["answer"]["main"] ?? "",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(
              "መልስ:",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 2),
            child: Text(
              question["answer"]["translation"] ?? "",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // ...existing code...
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF323232), // <-- changed here
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "Edit answer...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
                ),
              ),
// ...existing code...
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3366FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => onSend(controller.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
