"use client";

import { useState, useEffect } from "react";
import type { Flight } from "../types/flight";

// Mock data for demonstration
const mockFlights: Flight[] = [
  {
    id: "1",
    title: "My First Trip to USA",
    origin: "Ethiopia",
    destination: "USA",
    date: "Mar 28, 2025",
  },
  {
    id: "2",
    title: "Family Trip",
    origin: "Dubai",
    destination: "France",
    date: "Jan 20, 2025",
  },
  {
    id: "3",
    title: "Pick up the package ordered online",
    origin: "Ethiopia",
    destination: "China",
    date: "Jun 9, 2024",
  },
];

export function useFlights() {
  const [flights, setFlights] = useState<Flight[]>([]);
  const [selectedFlightId, setSelectedFlightId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulate API call
    const fetchFlights = async () => {
      try {
        // In a real app, this would be an API call
        await new Promise((resolve) => setTimeout(resolve, 500));
        setFlights(mockFlights);
      } catch (error) {  
        console.error("Failed to fetch flights:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchFlights();
  }, []);

  const addFlight = (flight: Omit<Flight, "id">) => {
    const newFlight = {
      ...flight,
      id: Date.now().toString(), // Simple ID generation
    };
    setFlights((prev) => [newFlight, ...prev]);
    return newFlight.id;
  };

  const deleteFlight = (id: string) => {
    setFlights((prev) => prev.filter((flight) => flight.id !== id));
    if (selectedFlightId === id) {
      setSelectedFlightId(null);
    }
  };

  const selectFlight = (id: string) => {
    setSelectedFlightId(id);
  };

  const getSelectedFlight = () => {
    return flights.find((flight) => flight.id === selectedFlightId) || null;
  };

  return {
    flights,
    loading,
    selectedFlightId,
    selectedFlight: getSelectedFlight(),
    addFlight,
    deleteFlight,
    selectFlight,
  };
}
