import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

class GetAllFlights {
  final FlightRepository repository;
  GetAllFlights(this.repository);
  Future<List<Flight>> call() => repository.getAllFlights();
}
