import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/flight_info/domain/entities/flight.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class FlightDetailPage extends StatelessWidget {
  final Flight flight;

  const FlightDetailPage({Key? key, required this.flight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Card> buildQuestionCards() {
      return flight.qa.map((question) {
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
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
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              question["question"]!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("ጥያቄ:",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          )),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              question["answer"]!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding:
                          const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                      decoration: const BoxDecoration(
                          color: Color(0xFF323232),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Answer:",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              )),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  question["question"]!,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("መልስ:",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              )),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  question["answer"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            flight.title,
            style: GoogleFonts.inter(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 45),
                  decoration: BoxDecoration(
                    color: const Color(0xFF676470),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _getDisplayLanguage(flight.language),
                      style: GoogleFonts.inter(
                          color: const Color(0xFFF5F5F5),
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 45),
                  decoration: BoxDecoration(
                    color: const Color(0xFF676470),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'English',
                      style: GoogleFonts.inter(
                          color: const Color(0xFFF5F5F5),
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: buildQuestionCards(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: const Color(0xFF3A86FF),
        onPressed: () {
          if (flight != null) {
            Navigator.pushNamed(
              context,
              '/flights/chat',
              arguments: flight,
            );
            print(flight);
          } else {
            print("Flight object is null!");
          }
        },
        label: Text(
          "USE FLIGHT",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

String _getDisplayLanguage(String lang) {
  switch (lang.toLowerCase()) {
    case 'amharic':
      return 'Amharic';
    case 'turkish':
      return 'Turkish';
    case 'english':
      return 'English';
    default:
      return lang.capitalize();
  }
}
