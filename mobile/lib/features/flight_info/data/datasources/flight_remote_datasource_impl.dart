import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'flight_remote_datasource.dart';
import '../models/flight_model.dart';

class FlightRemoteDatasourceImpl implements FlightRemoteDatasource {
  final ApiClient _apiClient;

  FlightRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<FlightModel>> fetchFlights() async {
    try {
      final response = await _apiClient.get("/flights", requiresAuth: true);
      print('=== API Response ===');
      print('Response: $response');
      print('Response type: ${response.runtimeType}');
      print('===================');

      // If response is null, return empty list
      if (response == null) {
        print('Response is null, returning empty list');
        return [];
      }

      // If response is not a list, return empty list
      if (response is! List) {
        print('Response is not a list, returning empty list');
        return [];
      }

      // If response is an empty list, return empty list
      if (response.isEmpty) {
        print('Response is empty list, returning empty list');
        return [];
      }

      final flights = response
          .map((json) {
            try {
              return FlightModel.fromJson(json);
            } catch (e) {
              print('Error parsing flight: $e');
              return null;
            }
          })
          .whereType<FlightModel>()
          .toList();

      print('Successfully parsed ${flights.length} flights');
      return flights;
    } catch (e) {
      print('Error fetching flights: $e');
      throw ServerException('Failed to fetch flights: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFlight(String flightId) async {
    try {
      final response = await _apiClient.delete(
        '/flights/$flightId',
        requiresAuth: true,
      );
      return response['message'];
    } catch (e) {
      throw ServerException('Failed to delete flight: ${e.toString()}');
    }
  }
}
