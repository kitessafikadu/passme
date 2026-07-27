import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MicButton extends StatefulWidget {
  final void Function(Map<String, dynamic> aiReply)? onAIResponse;
  final void Function(bool isRecording)? onRecordingChanged;
  final String? flightId;

  const MicButton(
      {super.key, this.onAIResponse, this.onRecordingChanged, this.flightId});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;

  Future<void> uploadAudio(String filePath) async {
    try {
      final uri =
          Uri.parse('https://7cab-196-189-152-26.ngrok-free.app/chat-ai');
      final request = http.MultipartRequest('POST', uri)
        ..fields['flight_id'] = widget.flightId ?? ''
        ..files.add(await http.MultipartFile.fromPath('audio', filePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        if (widget.onRecordingChanged != null) {
          widget.onRecordingChanged!(false);
        }
        print(responseBody);
        if (widget.onAIResponse != null) {
          widget.onAIResponse!(json.decode(responseBody));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Failed to get AI response. Please try again.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text(
            'Failed to upload audio. Make sure server is configured correctly.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) async {
        if (await audioRecorder.hasPermission()) {
          final Directory? externalDir =
              Directory('/storage/emulated/0/Download');

          if (!await externalDir!.exists()) {
            await externalDir.create(recursive: true);
          }

          final String filePath = p.join(externalDir.path, 'recording.mp3');

          await audioRecorder.start(const RecordConfig(), path: filePath);

          setState(() {
            isRecording = true;
          });
          if (widget.onRecordingChanged != null) {
            widget.onRecordingChanged!(true);
          }
        }
      },
      onLongPressEnd: (_) async {
        if (isRecording) {
          final String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
            });
            print("finished: $filePath");
            await uploadAudio(filePath); // Upload the audio file
          }
        } else {
          print("Recording was not active, stop() skipped.");
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording ? Colors.red : AppColors.primaryColor,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Record Officer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
