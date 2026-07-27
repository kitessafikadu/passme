import 'package:flutter/material.dart';
import 'package:mobile/features/form/domain/entites/question.dart';

class QuestionCard extends StatefulWidget {
  final QuestionEntity question;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isSelected,
    required this.onTap,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Initialize controller text if empty
    if (widget.controller.text.isEmpty && widget.question.answer != null) {
      widget.controller.text = widget.question.answer!;
    }
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if question changed from outside
    if (oldWidget.question.answer != widget.question.answer &&
        widget.controller.text != widget.question.answer) {
      widget.controller.text = widget.question.answer ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // Note: We don't dispose the controller here since it's managed by the parent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _focusNode.requestFocus();
      },
      child: Card(
        color: widget.isSelected
            ? Colors.blue.withOpacity(0.1)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          side: widget.isSelected
              ? const BorderSide(color: Colors.blueAccent)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.question.id}. ',
                      style: const TextStyle(
                        color: Color(0xff3972FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: widget.question.questionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.question.placeholder,
                  hintStyle: const TextStyle(color: Colors.white54),
                  fillColor: Colors.black12,
                  filled: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                maxLines: null, // Allows for multiline input
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
