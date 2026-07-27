import 'package:mobile/features/flight_info/domain/entities/flight.dart';

abstract class FlightRepository {
  Future<List<Flight>> getAllFlights();
  Future<void> deleteFlight(String flightId);
}
