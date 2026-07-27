part of 'flight_bloc.dart';

abstract class FlightEvent extends Equatable {
  const FlightEvent();

  @override
  List<Object> get props => [];
}

class LoadFlightsEvent extends FlightEvent {
  const LoadFlightsEvent();
}

class DeleteFlightEvent extends FlightEvent {
  final String flightId;

  const DeleteFlightEvent(this.flightId);

  @override
  List<Object> get props => [flightId];
}//