import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/chat/presentation/widget/edit_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnswerBubble extends StatefulWidget {
  final Map<String, dynamic> question;
  final bool isListening;
  final VoidCallback? onStateChanged;

  const AnswerBubble({
    super.key,
    required this.question,
    this.isListening = false,
    this.onStateChanged,
  });

  @override
  State<AnswerBubble> createState() => _AnswerBubbleState();
}

class _AnswerBubbleState extends State<AnswerBubble> {
  late bool isAccepted;
  late bool isDeclined;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isAccepted = false;
    isDeclined = false;
    isEditing = false;
  }

  void handleAccept() {
    setState(() {
      isAccepted = true;
      widget.question["isAccepted"] = true;
      isDeclined = false;
    });
    widget.onStateChanged?.call();
  }

  void handleDecline() {
    setState(() {
      isDeclined = true;
    });
    widget.onStateChanged?.call();
  }

  Future<void> handleEditSend(String newValue) async {
    final url = Uri.parse('https://translator-api-3etv.onrender.com/manual-answer');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'input': newValue});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final translation = responseData['translation'];
        final pronunciation = responseData['pronunciation'];
        final audio = responseData['audio'];

        setState(() {
          widget.question["answer"]["translation"] = translation;
          widget.question["answer"]["pronounciation"] = pronunciation;
          widget.question["answer"]["audio"] = audio;
          isDeclined = false;
          isAccepted = true;
        });
        widget.onStateChanged?.call();
      } else {
        print('Request failed with status: ${response.statusCode}.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update answer. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please check your internet connection and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDeclined
        ? EditInput(
      initialValue: widget.question["answer"]["translation"] ?? "",
      question: Map<String, dynamic>.from(widget.question),
      onSend: handleEditSend,
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF323232),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isListening)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      AnimatedUpdatingIcon(),
                      const SizedBox(width: 12),
                      Text(
                        "Updating...",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.question["answer"]["main"] ?? "",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Expanded(
                    child: Text(
                      "መልስ:",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 8),
                  child: Text(
                    isAccepted ? widget.question["answer"]["pronounciation"] : widget.question["answer"]["translation"],
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (!isAccepted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleDecline,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedListeningIcon extends StatefulWidget {
  @override
  State<AnimatedListeningIcon> createState() => _AnimatedListeningIconState();
}

class _AnimatedListeningIconState extends State<AnimatedListeningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(Icons.mic, color: Colors.blue, size: 24),
    );
  }
}

class AnimatedUpdatingIcon extends StatefulWidget {
  @override
  State<AnimatedUpdatingIcon> createState() => _AnimatedUpdatingIconState();
}

class _AnimatedUpdatingIconState extends State<AnimatedUpdatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.update, color: Colors.blue, size: 24),
    );
  }
}