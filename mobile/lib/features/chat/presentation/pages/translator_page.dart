import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/chat/presentation/widget/answer_bubble.dart';
import 'package:mobile/features/chat/presentation/widget/edit_input.dart';
import 'package:mobile/features/chat/presentation/widget/question_bubble.dart';
import '../widget/mic_button.dart';
import 'package:mobile/features/flight_info/domain/entities/flight.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final List<Map<String, dynamic>> questionData = [];
  bool isListening = false;
  final ScrollController _scrollController = ScrollController();
  Flight? flight; // To store the flight object

  @override
  void initState() {
    super.initState();
    // Retrieve the flight object from the route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Flight) {
        setState(() {
          flight = args;
        });
      }
    });
    // Ensure the initial scroll position after the layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Check if scrolling is needed
      if (_scrollController.position.maxScrollExtent > _scrollController.position.pixels) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void addQuestionAnswer(Map<String, dynamic> qa) {
    setState(() {
      qa["isAccepted"] = false;
      qa["isDeclined"] = false;
      questionData.add({...qa, "isListening": false});
    });
    // Scroll to bottom after the layout is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Flight in build method: $flight"); // Add this line
    List<Card> buildQuestionCards() {
      return questionData.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;

        return Card(
          elevation: 0.0,
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFF26252A),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionBubble(
                  question: question,
                  isListening: question["isListening"] ?? false,
                ),
                AnswerBubble(
                  question: question,
                  isListening: question["isListening"] ?? false,
                  onStateChanged: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF26252A),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          flight?.title ?? "My First Trip to USA",
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 45),
                  decoration: BoxDecoration(
                    color: const Color(0xFF676470),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      "English",
                      style: GoogleFonts.inter(
                        color: const Color(0xFFF5F5F5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 45),
                  decoration: BoxDecoration(
                    color: const Color(0xFF676470),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      flight?.language.capitalize() ?? "Amharic",
                      style: GoogleFonts.inter(
                        color: const Color(0xFFF5F5F5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                controller: _scrollController,
                shrinkWrap: true,
                children: buildQuestionCards(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: questionData.isNotEmpty &&
          !(questionData.last["isAccepted"] ?? false) &&
          !(questionData.last["isDeclined"] ?? false) &&
          !(questionData.last["isListening"] ?? false)
          ? null
          : MicButton(
        flightId: flight?.id, // Pass the flight ID to MicButton
        onAIResponse: (Map<String, dynamic> qa) {
          setState(() {
            // Remove the placeholder question if it exists
            if (questionData.isNotEmpty) {
              questionData.removeLast();
            }
            // Add the new question-answer pair
            addQuestionAnswer(qa);
          });
        },
        onRecordingChanged: (bool isRecording) {
          setState(() {
            this.isListening = isRecording;

            if (isRecording) {
              // Add a placeholder question with isListening = true
              questionData.add({
                "question": {"main": "", "translated": ""},
                "answer": {"main": "", "translation": ""},
                "isListening": true,
              });
            } else if (questionData.isNotEmpty) {
              // Update the last question's isListening to false
              questionData.last["isListening"] = false;
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}