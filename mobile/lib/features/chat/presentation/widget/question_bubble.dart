import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/chat/presentation/widget/answer_bubble.dart';

class QuestionBubble extends StatefulWidget {
  final Map<String, dynamic> question;
  final bool isListening;

  const QuestionBubble({super.key, required this.question, this.isListening = false});

  @override
  State<QuestionBubble> createState() => _QuestionBubbleState();
}

class _QuestionBubbleState extends State<QuestionBubble> {
  @override
Widget build(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      widget.isListening
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  AnimatedListeningIcon(),
                  const SizedBox(width: 12),
                  Text(
                    "Listening...",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question:",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 2),
                    child: Text(
                      widget.question["question"]["main"] ?? "",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ጥያቄ:",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 2),
                    child: Text(
                      widget.question["question"]["translated"] ?? "",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    ],
  );
}
}