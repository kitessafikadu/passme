import 'package:mobile/core/usecase/usecase.dart';

import '../entities/flight.dart';
import '../repositories/flight_repository.dart';

class DeleteFlight {
  final FlightRepository repository;

  DeleteFlight(this.repository);

  @override
  Future<void> call(String flightId) {
    return repository.deleteFlight(flightId);
  }
}
