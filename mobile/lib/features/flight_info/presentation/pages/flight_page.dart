import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/flight_info/presentation/blocs/flight_bloc.dart';
import 'package:mobile/features/flight_info/presentation/widgets/single_flight.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/flight.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({super.key});

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  String searchQuery = '';
  String filterFromCountry = '';
  String filterToCountry = '';
  String sortOption = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FlightBloc>()..add(LoadFlightsEvent()),
      child: BlocListener<FlightBloc, FlightState>(
        listener: (context, state) {
          if (state is FlightOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/images/logo.png', height: 35),
            backgroundColor: AppColors.backgroundColor,
            centerTitle: true,
          ),
          backgroundColor: AppColors.backgroundColor,
          body: BlocBuilder<FlightBloc, FlightState>(
            builder: (context, state) {
              if (state is FlightLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FlightError) {
                return Center(child: Text(state.message));
              } else if (state is FlightLoaded) {
                return _buildFlightList(context, state.flights);
              } else if (state is FlightInitial) {
                return _buildEmptyState(context);
              }
              return const Center(child: Text('Unknown state'));
            },
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'main-fab',
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.pushNamed(context, '/form');
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColors.backgroundColor,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white70,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                activeIcon: Icon(Icons.home, color: Colors.blue),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
                activeIcon: Icon(Icons.person, color: Colors.blue),
              ),
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/profile');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(Icons.flight, size: 48, color: Colors.white),
        const SizedBox(height: 16),
        const Text(
          "No Flight Details Yet",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
          child: Text(
            "Start by adding your travel info — origin, destination, reason, and more — so we can help you communicate clearly at your destination",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildFlightList(BuildContext context, List<Flight> flights) {
    return BlocBuilder<FlightBloc, FlightState>(
      builder: (context, state) {
        List<Flight> filteredFlights = flights
            .where((flight) =>
                flight.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        if (filterFromCountry.isNotEmpty) {
          filteredFlights = filteredFlights
              .where((flight) => flight.fromCountry == filterFromCountry)
              .toList();
        }

        if (filterToCountry.isNotEmpty) {
          filteredFlights = filteredFlights
              .where((flight) => flight.toCountry == filterToCountry)
              .toList();
        }

        if (sortOption == 'title') {
          filteredFlights.sort((a, b) => a.title.compareTo(b.title));
        } else if (sortOption == 'date') {
          filteredFlights.sort((a, b) => a.date.compareTo(b.date));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Find",
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.grey[900],
                          context: context,
                          builder: (_) => _buildFilterSheet(),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredFlights.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<FlightBloc>().add(LoadFlightsEvent());
                        },
                        child: ListView.builder(
                          itemCount: filteredFlights.length,
                          itemBuilder: (context, index) {
                            final flight = filteredFlights[index];
                            final isDeleting = state is FlightLoading &&
                                state.deletingFlightId == flight.id;
                            return Dismissible(
                              key: Key(flight.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                        "Are you sure you want to delete this flight?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                context.read<FlightBloc>().add(
                                      DeleteFlightEvent(flight.id),
                                    );
                              },
                              child: SingleFlight(
                                flight: flight,
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                          "Are you sure you want to delete this flight?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.read<FlightBloc>().add(
                                                  DeleteFlightEvent(flight.id),
                                                );
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                isDeleting: isDeleting,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSheet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Filter From Country",
              labelStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                filterFromCountry = value;
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: "Filter To Country",
              labelStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                filterToCountry = value;
              });
            },
          ),
          DropdownButton<String>(
            value: sortOption.isEmpty ? null : sortOption,
            hint:
                const Text("Sort By", style: TextStyle(color: Colors.white70)),
            dropdownColor: Colors.grey[900],
            items: const [
              DropdownMenuItem(
                value: 'title',
                child: Text("Title", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'date',
                child: Text("Date", style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                sortOption = value ?? '';
              });
            },
          ),
        ],
      ),
    );
  }
}
