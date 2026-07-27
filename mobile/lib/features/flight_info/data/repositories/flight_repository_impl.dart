import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';
import '../datasources/flight_remote_datasource.dart';
import '../models/flight_model.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightRemoteDatasource remoteDatasource;

  FlightRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<FlightModel>> getAllFlights() async {
    //if (await networkInfo.isConnected) {
    final flights = await remoteDatasource.fetchFlights();
    return flights;
    //    .map((flight) => FlightModel.fromJson(flight as Map<String, dynamic>))
    //    .toList();
    //} else {
    //  throw Exception('No internet connection');
    //}
  }

  @override
  Future<void> deleteFlight(String flightId) async =>
      await remoteDatasource.deleteFlight(flightId);
}
