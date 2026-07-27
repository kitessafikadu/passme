import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/flight_info/domain/usecases/get_all_flights.dart';
import 'package:mobile/features/flight_info/domain/usecases/delete_flight.dart';
import 'package:mobile/features/flight_info/data/models/flight_model.dart';

part 'flight_event.dart';
part 'flight_state.dart';

class FlightBloc extends Bloc<FlightEvent, FlightState> {
  final GetAllFlights getFlights;
  final DeleteFlight deleteFlight;

  FlightBloc({
    required this.getFlights,
    required this.deleteFlight,
  }) : super(FlightInitial()) {
    on<LoadFlightsEvent>(_onLoadFlights);
    on<DeleteFlightEvent>(_onDeleteFlight);
  }

  Future<void> _onLoadFlights(
    LoadFlightsEvent event,
    Emitter<FlightState> emit,
  ) async {
    emit(FlightLoading());
    try {
      final flights = await getFlights();
      final flightModels = flights.map(FlightModel.fromFlight).toList();
      emit(FlightLoaded(flightModels));
    } catch (e) {
      emit(FlightError(e.toString()));
      // Consider adding error recovery or retry logic
    }
  }

  Future<void> _onDeleteFlight(
    DeleteFlightEvent event,
    Emitter<FlightState> emit,
  ) async {
    final currentState = state;

    try {
      // Show loading state while deleting
      if (currentState is FlightLoaded) {
        emit(FlightLoading(deletingFlightId: event.flightId));
      }

      // Perform deletion
      await deleteFlight(event.flightId);

      // Show success message
      emit(FlightOperationSuccess('Flight deleted successfully'));

      // Update the list immediately (optimistic update)
      if (currentState is FlightLoaded) {
        final updatedFlights = currentState.flights
            .where((flight) => flight.id != event.flightId)
            .toList();
        emit(FlightLoaded(updatedFlights));
      }

      // Optionally: Reload fresh data from API
      add(LoadFlightsEvent());
    } catch (e) {
      // Revert to previous state if error occurs
      if (currentState is FlightLoaded) {
        emit(currentState);
      }
      emit(FlightError('Failed to delete flight: ${e.toString()}'));
    }
  }
}
//
