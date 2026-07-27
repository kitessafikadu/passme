import '../models/flight_model.dart';

abstract class FlightRemoteDatasource {
  Future<List<FlightModel>> fetchFlights();
  Future<void> deleteFlight(String flightId);
}
