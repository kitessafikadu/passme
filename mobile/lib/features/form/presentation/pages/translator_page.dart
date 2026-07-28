import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/form/presentation/blocs/form_bloc.dart';
import 'package:mobile/features/form/presentation/widgets/question_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../injection_container.dart';
import '../../data/datasource/question_remote_datasource.dart'
    show QuestionRemoteDataSourceImpl;

import '../../domain/entites/Submission_entity.dart';
import '../../domain/entites/question.dart';

class TranslatorFormPage extends StatelessWidget {
  const TranslatorFormPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FormBloc>(), // Get instance from GetIt
      child: const _TranslatorFormView(),
    );
  }
}

class _TranslatorFormView extends StatefulWidget {
  const _TranslatorFormView();

  @override
  State<_TranslatorFormView> createState() => _TranslatorFormViewState();
}

class _TranslatorFormViewState extends State<_TranslatorFormView> {
  DateTime? _selectedDate;
  int _selectedCardIndex = -1;
  Language _selectedLanguage = Language.english;
  Language _targetLanguage = Language.amharic;
  final TextEditingController _flightNameController = TextEditingController();
  final TextEditingController _startNameController = TextEditingController();
  final TextEditingController _destinationNameController =
      TextEditingController();
  final Map<String, TextEditingController> _answerControllers = {};

  @override
  void initState() {
    super.initState();
    // Load questions for the default language on page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormBloc>().add(LoadQuestions(_selectedLanguage));
    });
  }
  String _getLanguage() {
    switch (_selectedLanguage) {
      case Language.english:
        return "english";
      case Language.amharic:
        return "amharic";
      case Language.turkish:
        return "turkish";
      default:
        return "amharic"; // fallback
    }
  }

  String _getLocalizedText(String english, String amharic, String turkish) {
    switch (_selectedLanguage) {
      case Language.english:
        return english;
      case Language.amharic:
        return amharic;
      case Language.turkish:
        return turkish;
      default:
        return english; // fallback
    }
  }

  @override
  void dispose() {
    _flightNameController.dispose();
    _startNameController.dispose();
    _destinationNameController.dispose();
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _submitText => _getLocalizedText("submit", "አስገባ", "Gönder");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/images/logo.png',
            height: 32,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<FormBloc, FormsSates>(
        listener: (context, state) {
          if (state is SubmissionSuccess) {
            _showSuccessSnackbar(context);
          } else if (state is SubmissionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Selector
                _buildLanguageSectionHeader(),
                const SizedBox(height: 10),
                Visibility(
                  visible: false,
                  child: Text(
                  _getLocalizedText("Choose language", "ቋንቋ ይምረጡ", "Dil seçin"),
                  style: const TextStyle(color: Colors.white),
                ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLanguageSelectors(context),
                const SizedBox(height: 5),
                _buildCountryInputColumn(
                  controller: _flightNameController,
                  hint: _getLocalizedText(
                      "Enter flight name", "የበረራ ስም አስገባ", "Uçuş adını girin"),
                  label:
                      _getLocalizedText("Flight Name", "የበረራ ስም", "Uçuş Adı"),
                ),
                const SizedBox(height: 10),
                _buildStartandDestinationPlace(context),
                const SizedBox(height: 5),
                Text(
                  _getLocalizedText("Choose date of flight", "የበረራ ቀን ይምረጡ",
                      "Uçuş tarihini seçin"),
                  style: const TextStyle(color: Colors.grey),
                ),
                _buildDatePickerButton(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3972FF).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.question_answer_outlined,
                        color: Color(0xFF3972FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                      _getLocalizedText(
                          "Common Airport Questions",
                          "በተለምዶ አየር መንገድ ላይ  የሚጠየቁ ጥያቄዎች",
                          "Genel Havaalanı Soruları"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuestionsList(context, state),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSectionHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF3972FF).withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.language_outlined,
            color: Color(0xFF3972FF),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _getLocalizedText(
            'Choose Language',
            'á‰‹áŠ•á‰‹ á‹­áˆáˆ¨áŒ¡',
            'Dil seÃ§in',
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStartandDestinationPlace(BuildContext context) {
    return IntrinsicHeight(
      // Add this wrapper
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align at the top
        children: [
          Expanded(
            // Keep Expanded here
            child: _buildCountryInputColumn(
              label: _getLocalizedText("From Country", "ከዚህ ሃገር", "Ülkeden"),
              hint: _getLocalizedText("Country name", "የሃገር ስም", "Ülke adı"),
              controller: _startNameController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            // Keep Expanded here
            child: _buildCountryInputColumn(
              label: _getLocalizedText("To Country", "ወደዚህ ሃገር", "Ülkeye"),
              hint: _getLocalizedText(
                "Country name",
                "የሃገር ስም",
                "Ülke adı",
              ),
              controller: _destinationNameController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryInputColumn({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // This prevents extra space
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E2E),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF676470)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF676470)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLanguageSelectors(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LanguageSelector(
            selectedLanguage: _selectedLanguage,
            onChanged: (lang) => _handleLanguageChange(context, lang),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.compare_arrows, color: Colors.white),
        ),
        Expanded(
          child: LanguageSelector(
            selectedLanguage: _targetLanguage,
            onChanged: (lang) => setState(() => _targetLanguage = lang),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _pickDate(context),
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: Text(
          _selectedDate == null
              ? _getLocalizedText("Select Date", "ቀን ይምረጡ", "Tarih Seçin")
              : DateFormat('EEEE, MMMM d, y').format(_selectedDate!),
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0Xff676470),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context, FormsSates state) {
    if (state is QuestionsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is QuestionsError) {
      return Center(child: Text(state.message));
    } else if (state is QuestionsLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.questions.length + 1,
        itemBuilder: (ctx, index) {
          if (index < state.questions.length) {
            final question = state.questions[index];
            // Get or create controller for this question
            final controller = _answerControllers.putIfAbsent(
              question.id.toString(),
              () => TextEditingController(text: question.answer ?? ''),
            );

            return BlocBuilder<FormBloc, FormsSates>(
              builder: (context, blocState) {
                final currentState =
                    blocState is QuestionsLoaded ? blocState : state;
                final updatedQuestion = currentState.questions[index];

                // Update controller text if answer changed from outside
                if (controller.text != updatedQuestion.answer) {
                  controller.text = updatedQuestion.answer ?? '';
                }

                return QuestionCard(
                  question: updatedQuestion,
                  isSelected: index == _selectedCardIndex,
                  onTap: () => setState(() => _selectedCardIndex = index),
                  onChanged: (value) {
                    context.read<FormBloc>().add(
                          UpdateAnswer(
                            question.id.toString(),
                            value,
                          ),
                        );
                  },
                  controller: controller,
                );
              },
            );
          } else {
            return _buildSubmitButton(context, state.questions);
          }
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSubmitButton(
      BuildContext context, List<QuestionEntity> questions) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _handleSubmit(context, questions),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _submitText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, Language lang) {
    setState(() {
      _selectedLanguage = lang;
      _selectedCardIndex = -1;
    });
    context.read<FormBloc>().add(LoadQuestions(lang));
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit(
      BuildContext context, List<QuestionEntity> questions) async {
    if (!_validateForm(questions, context)) return;

    // Get the bloc before showing dialog
    final formBloc = context.read<FormBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _getLocalizedText("Confirmation", "ማረጋገጫ", "Onay"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            _getLocalizedText(
              "Are you sure you want to save this information?",
              "ይህንን መረጃ ለማስቀመጥ እርግጠኛ ነዎት?",
              "Bu bilgiyi kaydetmek istediğinizden emin misiniz?",
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _getLocalizedText(
                    "Back to Edit", "ለማስተካከል ይመለሱ", "Düzenlemeye Dön"),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                formBloc.add(
                  SubmitAnswers(
                    SubmissionEntity(
                      qa: questions,
                      date: _selectedDate!,
                      title: _flightNameController.text.trim(),
                      from_country: _startNameController.text.trim(),
                      to_country: _destinationNameController.text.trim(),
                      language: _getLanguage(),
                    ),
                  ),
                );
              },
              child: Text(
                _getLocalizedText("Yes", "አዎ", "Evet"),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateForm(List<QuestionEntity> questions, BuildContext context) {
    // Check all validations first
    final allQuestionsAnswered =
        questions.every((q) => q.answer?.isNotEmpty == true);
    final languagesDifferent = _selectedLanguage != _targetLanguage;
    final dateSelected = _selectedDate != null;

    // If any validation fails, show appropriate error and return false
    if (!allQuestionsAnswered) {
      _showValidationError(
        context,
        _getLocalizedText(
          "Please answer all questions",
          "እባክዎ ሁሉንም ጥያቄዎች ይመልሱ",
          "Lütfen tüm soruları cevaplayın",
        ),
      );
      return false;
    }
    if (_flightNameController.text.trim().isEmpty) {
      _showValidationError(
        context,
        _getLocalizedText(
          "Please enter flight name",
          "እባክዎ የበረራ ስም ያስገቡ",
          "Lütfen uçuş adını girin",
        ),
      );
      return false;
    }
    if (_destinationNameController.text.trim().isEmpty) {
      _showValidationError(
        context,
        _getLocalizedText(
          "Please enter destination country",
          "እባክዎ የመድረሻ ሀገር ያስገቡ",
          "Lütfen varış ülkesini girin",
        ),
      );
      return false;
    }
    if (_startNameController.text.trim().toLowerCase() ==
        _destinationNameController.text.trim().toLowerCase()) {
      _showValidationError(
        context,
        _getLocalizedText(
            "Departure and destination cannot be the same",
            "መነሻ እና መድረሻ ተመሳሳይ ሊሆኑ አይችሉም",
            "Kalkış ve varış noktaları aynı olamaz"),
      );
      return false;
    }

    if (!languagesDifferent) {
      _showValidationError(
        context,
        _getLocalizedText(
            "Source and target languages cannot be the same",
            "የመነሻ እና የመዳረሻ ቋንቋዎች መመሳሰል �ይለበትም",
            "Kaynak ve hedef diller aynı olamaz"),
      );
      return false;
    }

    if (!dateSelected) {
      _showValidationError(
        context,
        _getLocalizedText("Please select a flight date", "እባክዎ የበረራ ቀን ይምረጡ",
            "Lütfen uçuş tarihini seçin"),
      );
      return false;
    }

    return true;
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getLocalizedText(
              "Submission successful!", "በትክክል ቀርቧል!", "Gönderim başarılı!"),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, '/flights');
  }
}
