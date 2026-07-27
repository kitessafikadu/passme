"use client";

import { useRouter } from "next/navigation";
import Image from "next/image";
import { useGetFlightQuery } from "@/app/services/flightsApi";
import { Send } from "lucide-react";


export default function FlightDetail({ flightId }: { flightId: string }) {
  const router = useRouter();
  const { data, isLoading } = useGetFlightQuery(flightId)

  const selectedConversation = data?.qa;

  const handleUseChat = (flightId: { flightId: string }) => {
    const params = new URLSearchParams({
      flightId: flightId.flightId,
    });

    router.push(`/dashboard/chat?${params.toString()}`);
  };

  if (!selectedConversation && isLoading) {
    return (
      <div className="flex-1 flex flex-col items-center h-full relative bg-[#1A1A1A] text-white">
        <div className="flex justify-center items-center py-1 sticky top-0 bg-[#1A1A1A] z-10">
          <Image
            src="/banner.png"
            alt="A2SV Translator Banner"
            width={333}
            height={62}
            className="w-[180px] md:w-[220px] md:h-auto object-contain"
            priority
          />
        </div>
        <p className="text-gray-400">
          Loading ...
        </p>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col h-full bg-[#1A1A1A] text-white overflow-y-auto">
      {/* Banner at the top, horizontally centered */}
      <div className="flex justify-center items-center py-1 sticky top-0 bg-[#1A1A1A] z-10">
        <Image
          src="/banner.png"
          alt="A2SV Translator Banner"
          width={333}
          height={62}
          className="w-[180px] md:w-[220px] md:h-auto object-contain"
          priority
        />
      </div>

      <div className="px-8 pb-20 relative">
        {/* Date selection - as shown in the UI */}
        <div className="mb-8">
          <span className="text-gray-400 text-sm block mb-1">
            Your date of flight
          </span>
          <div className="bg-[#5D5D6D] text-white rounded-md md:p-3 p-1 md:w-[240px] w-[200px] flex justify-center items-center">
            <span>{new Date(data?.date ?? "").toLocaleDateString('en-GB', { weekday: 'long' }) + ', ' + new Date(data?.date ?? "").toLocaleDateString('en-GB', { day: 'numeric', month: 'long' })}
            </span>
          </div>
        </div>

        {/* Conversation messages */}
        <div className="max-w-3xl mx-auto flex flex-col space-y-4">
          {selectedConversation?.map((message, idx) => (
            <div key={idx} className="flex flex-col space-y-4">
              {/* Question bubble */}
              <div className="flex flex-col max-w-md self-start space-y-1">
                <div className="rounded-lg px-2 py-1 min-w-[250px] bg-[#26252A] text-sm whitespace-pre-wrap">
                  <span className="text-sm text-gray-400">
                    Question:
                  </span>
                  <p>{message.question}</p>
                </div>
              </div>

              {/* Answer bubble */}
              {message.answer ? (
                <div className="flex flex-col max-w-md self-end space-y-1">
                  <div className="rounded-lg px-2 py-1 min-w-[250px] bg-[#323232] text-sm whitespace-pre-wrap">
                    <span className="text-sm text-green-100">Answer:</span>
                    <p>{message.answer}</p>
                  </div>
                </div>
              ) : null}
            </div>
          ))}
        </div>
        {/* Use Chat button with specified dimensions */}
        <div className="fixed bottom-6 right-10">
          <button
            onClick={() => handleUseChat({ flightId })}
            className="px-8 py-4 bg-[#3972FF] hover:bg-blue-600 text-white rounded-[10px] gap-[8px] flex items-center justify-center"
          >
            <Send size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
