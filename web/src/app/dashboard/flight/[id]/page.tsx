"use client";

import { useParams } from "next/navigation";
import FlightDetail from "../../../components/flight-detail/flight-detail";

export default function FlightDetailPage() {
  const params = useParams();
  const flightId = params.id as string;

  return (
    <div className="h-screen bg-[#121212]">
      <FlightDetail flightId={flightId} />
    </div>
  );
}
