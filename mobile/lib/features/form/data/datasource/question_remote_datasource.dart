import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mobile/features/form/data/models/question_model.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/service/local_storage_service.dart';

abstract class QuestionRemoteDataSource {
  Future<List<QuestionModel>> getQuestions(String languageCode);
  Future<void> submitAnswers(Map<String, dynamic> data);
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  QuestionRemoteDataSourceImpl(this._apiClient, this._localStorage);
  @override
  Future<List<QuestionModel>> getQuestions(String languageCode) async {
    final jsonString =
        await rootBundle.loadString('assets/questions_$languageCode.json');
    print(jsonString);
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => QuestionModel.fromJson(e)).toList();
  }

  @override
  Future<void> submitAnswers(Map<String, dynamic> data) async {
    try {
      print('Submitting: ${jsonEncode(data)}'); // Debug what you're sending

      final response = await _apiClient.post(
        '/flights',
        data,
        requiresAuth: true, // Explicitly enable auth
      );

      print('Response: $response'); // Debug the response
    } catch (e) {
      print('Full error: $e'); // Get complete error details
      if (e is ApiException) {
        print('Status code: ${e.statusCode}');
        print('Response body: ${e.response}');

        if (e.statusCode == 401) {
          throw Exception('Session expired. Please login again.');
        } else if (e.statusCode == 400) {
          throw Exception(
              'Invalid request: ${e.response['message'] ?? 'Bad request'}');
        }
      }
      throw Exception('Submission failed: ${e.toString()}');
    }
  }
}
