part of 'flight_bloc.dart';

abstract class FlightState extends Equatable {
  const FlightState();

  @override
  List<Object> get props => [];
}

class FlightInitial extends FlightState {}

class FlightLoading extends FlightState {
  final String? deletingFlightId;
  const FlightLoading({this.deletingFlightId});

  @override
  List<Object> get props => [deletingFlightId ?? ''];
}

class FlightLoaded extends FlightState {
  final List<FlightModel> flights;

  const FlightLoaded(this.flights);

  @override
  List<Object> get props => [flights];
}

class FlightOperationSuccess extends FlightState {
  final String message;

  const FlightOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FlightError extends FlightState {
  final String message;

  const FlightError(this.message);

  @override
  List<Object> get props => [message];
}
//
