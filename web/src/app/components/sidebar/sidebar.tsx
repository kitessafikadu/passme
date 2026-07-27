"use client";

import { signOut } from "next-auth/react";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import {
  useGetFlightsQuery,
  useDeleteFlightMutation,
} from "../../services/flightsApi";
import { useGetProfileQuery } from "@/app/services/profileApi";
import ChangePasswordModal from "@/app/components/modals/ChangePasswordModal";
import ChangeUsernameModal from "@/app/components/modals/ChangeUsernameModal";
import AboutModal from "@/app/components/modals/AboutModal";

interface Flight {
  id: string;
  title: string;
  from_country: string;
  to_country: string;
  date: string;
}

export default function Sidebar() {
  const { data, isLoading } = useGetFlightsQuery();
  const [deleteFlight] = useDeleteFlightMutation();

  const flights: Flight[] = (data ?? []).map(
    ({ id, title, from_country, to_country, date }: Flight) => ({
      id,
      title,
      from_country,
      to_country,
      date,
    })
  );
  flights.reverse();
  const router = useRouter();
  const [selectedFlightId, setSelectedFlightId] = useState<string | null>(null);
  const [showAccountModal, setShowAccountModal] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Modal states
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showUsernameModal, setShowUsernameModal] = useState(false);
  const {
    data: profileData,
    isLoading: isProfileLoading,
  } = useGetProfileQuery();

  useEffect(() => {
    const checkIfMobile = () => {
      const mobile = window.innerWidth < 768;
      setIsMobile(mobile);

      // Auto-hide sidebar on mobile
      if (mobile) {
        setIsSidebarOpen(false);
      } else {
        setIsSidebarOpen(true);
      }
    };

    checkIfMobile();
    window.addEventListener("resize", checkIfMobile);

    return () => window.removeEventListener("resize", checkIfMobile);
  }, []);

  // Update layout when sidebar state changes
  useEffect(() => {
    const mainContent = document.getElementById("main-content");
    if (mainContent) {
      if (isSidebarOpen) {
        mainContent.classList.add("md:ml-[422px]");
        mainContent.classList.remove("ml-0");
      } else {
        mainContent.classList.remove("md:ml-[422px]");
        mainContent.classList.add("ml-0");
      }
    }
  }, [isSidebarOpen]);

  const handleDeleteFlight = async (id: string) => {
    try {
      await deleteFlight(id).unwrap();
      if (selectedFlightId === id) {
        setSelectedFlightId(null);
        router.push("/dashboard");
      }
    } catch (err) {
      console.error("Failed to delete flight", err);
    }
  };

  const handleSelectFlight = (id: string) => {
    setSelectedFlightId(id);
    router.push(`/dashboard/flight/${id}`);
    if (isMobile) {
      setIsSidebarOpen(false);
    }
  };

  const handleNewChat = () => {
    setSelectedFlightId(null);
    router.push("/dashboard/newflight");
    if (isMobile) {
      setIsSidebarOpen(false);
    }
  };

  const toggleAccountModal = () => {
    setShowAccountModal(!showAccountModal);
  };

  const handleLogout = async () => {
    await signOut({ redirect: false });
    router.push("/home");
  };

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  return (
    <>
      {/* Toggle button that appears when sidebar is closed */}
      {!isSidebarOpen && (
        <button
          onClick={toggleSidebar}
          className="fixed top-4 left-4 z-40 bg-[#1A1A1A] p-2 rounded-full shadow-lg"
          aria-label="Open sidebar"
        >
          <Image
            src="/image.png"
            alt="Open sidebar"
            width={24}
            height={24}
            className="transform rotate-180"
          />
        </button>
      )}

      {/* Main sidebar */}
      <div
        className={`
          fixed md:absolute z-30
          flex flex-col h-full bg-[#1A1A1A] text-white 
          md:w-[422px] w-[85%] 
          border-r border-gray-800
          transition-all duration-300 ease-in-out
          ${isSidebarOpen ? "left-0" : "-left-full md:-left-full"}
        `}
      >
        <div className="flex justify-between items-center p-4 py-10">
          {/* Close sidebar button - visible on all devices */}
          <button
            onClick={toggleSidebar}
            className="flex items-center justify-center mr-1"
            aria-label="Close sidebar"
          >
            <Image
              src="/image.png"
              alt="Close sidebar"
              width={24}
              height={24}
            />
          </button>

          {/* New Chat Button */}
          <button
            onClick={handleNewChat}
            className="w-[260px] h-[40px] px-16 flex items-center justify-center gap-[4px] rounded-[12px] bg-white hover:bg-neutral-200 text-black mx-auto transition-colors cursor-pointer"
          >
            <span className="text-xl">+</span>
            <span>New chat</span>
          </button>
        </div>

        <div className="flex-1 flex flex-col overflow-hidden relative">
          {/* Flight History List */}
          <div className="flex-1 overflow-y-auto">
            {flights.length === 0 ? (
              !isLoading ? (
                <div className="flex flex-col items-center justify-center p-8 text-center h-full text-white">
                  <div
                    className="mb-4"
                    style={{
                      width: "62.274px",
                      height: "46.294px",
                      flexShrink: 0,
                    }}
                  >
                    <Image src='/planeline.png' height={200} width={200} alt="Plange line"/>
                  </div>

                  <h3
                    className="mb-4 text-center text-[20px] font-bold "
                  >
                    No Flight Details Yet
                  </h3>

                  <p
                    className="max-w-[300px] text-center text-[14px] font-normal"
                  >
                    Start by adding your travel info — origin, destination,
                    reason, and more — so we can help you communicate clearly at
                    your destination
                  </p>
                </div>
              ) : null
            ) : (
              <div className="flex flex-col py-4 gap-4">
                {flights.map((flight) => (
                  <div
                    key={flight.id}
                    onClick={() => handleSelectFlight(flight.id)}
                    className={`flex flex-col items-center py-2 px-4 w-full max-w-[95%] self-stretch cursor-pointer rounded-lg transition-colors ${flight.id === selectedFlightId ? "bg-[#3150E0]" : ""
                      }`}
                  >
                    <div className="flex w-full items-center justify-between">
                      {/* Left side: message icon and text */}
                      <div className="flex items-start gap-3">
                        {/* Message Icon */}
                        <div className="w-[42px] h-[42px]">
                          <Image
                            src="/messages.png"
                            alt="message icon"
                            width={42}
                            height={42}
                            className="object-contain aspect-square"
                          />
                        </div>

                        {/* Text Block */}
                        <div className="flex flex-col justify-center gap-[2px]">
                          {/* Title */}
                          <h3 className="text-[13px] leading-[20px] font-bold text-white font-['Inter']">
                            {flight.title}
                          </h3>

                          {/* Origin - Destination */}
                          <p className="text-[12px] leading-[20px] font-normal text-white/75 font-['Inter']">
                            {flight.from_country} - {flight.to_country}
                          </p>

                          {/* Date */}
                          <p className="text-[11px] leading-[20px] font-normal text-white/75 font-['Inter']">
                            {new Date(flight.date).toLocaleDateString("en-US", {
                              year: "numeric",
                              month: "long",
                              day: "numeric",
                            })}
                          </p>
                        </div>
                      </div>

                      {/* Trash Icon */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDeleteFlight(flight.id);
                        }}
                        className="p-1"
                        aria-label="Delete flight"
                      >
                        <Image
                          src="/trash.png"
                          alt="delete icon"
                          width={19}
                          height={22}
                          className="w-[19px] h-[22px] object-contain"
                        />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Bottom Navigation */}
        <div className="flex flex-col items-start gap-[4px] self-stretch p-5 border-t border-white/10">
          {/* Get the App */}
          <button
            onClick={() => { }}
            className="flex items-center w-full py-3 hover:bg-[#2A2A2A] transition-colors"
          >
            <Image
              src="/phone.png"
              alt="Get the App"
              width={20}
              height={20}
              className="mr-3"
            />
            <span>Get the App</span>
          </button>

          {/* My Account */}
          <button
            onClick={toggleAccountModal}
            className="flex items-center w-full py-3 hover:bg-[#2A2A2A] transition-colors"
          >
            <Image
              src="/User.png"
              alt="My Account"
              width={20}
              height={20}
              className="mr-3"
            />
            <span>My account</span>
          </button>

          {/* Logout */}
          <button
            onClick={handleLogout}
            className="flex items-center w-full py-3 hover:bg-[#2A2A2A] transition-colors"
          >
            <Image
              src="/SignOut.png"
              alt="Log out"
              width={20}
              height={20}
              className="mr-3"
            />
            <span>Log out</span>
          </button>
        </div>
      </div>

      {/* Account Modal */}
      {showAccountModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="inline-flex flex-col items-start gap-[10px] p-[40px] rounded-[12px] bg-[#202020] text-white w-full max-w-md relative">
            <button
              onClick={() => setShowAccountModal(false)}
              className="absolute top-4 right-4 text-white"
              aria-label="Close"
            >
              ✕
            </button>

            {/* User section */}
            <div className="py-3 w-full border-b-2 border-white-700">
              <div className="ml-0">
                <div className="flex items-center gap-2">
                  <h3 className="font-medium text-lg">
                    {isProfileLoading
                      ? "Loading..."
                      : profileData?.username || "Your name"}
                  </h3>
                  <button
                    onClick={() => setShowUsernameModal(true)}
                    className="cursor-pointer"
                    title="Edit Username"
                  >
                    <Image
                      src="/edit.png"
                      alt="Edit"
                      width={18}
                      height={18}
                      className="filter invert brightness-0"
                    />
                  </button>
                </div>
                <p className="text-l text-gray-400 pb-2">
                  {isProfileLoading
                    ? "Loading..."
                    : profileData?.email || "yourname@gmail.com"}
                </p>
              </div>
            </div>

            {/* Settings section */}
            <div className="w-full space-y-8 pt-8">
              <div className="flex justify-between items-center pb-5">
                <div className="flex items-center gap-2">
                  <Image src="/User.png" alt="User" width={40} height={40} />
                  <span className="text-lg font-medium">Change Password</span>
                </div>

                <button
                  onClick={() => setShowPasswordModal(true)}
                  className="cursor-pointer"
                >
                  <Image
                    src="/edit.png"
                    alt="Edit"
                    width={21}
                    height={21}
                    className="filter invert brightness-0"
                  />
                </button>
              </div>

              <div className="pb-5">
                <div className="flex items-center gap-2">
                  <Image src="/about.png" alt="About" width={40} height={40} />
                  <span className="font-medium text-lg">About</span>
                </div>
                <p className="text-gray-400 ml-12 mt-2">
                  {isProfileLoading
                    ? "Loading..."
                    : profileData?.about ||
                      "This app helps users schedule flights and translate queries."}
                </p>
              </div>

              <div>
                {/* Logout */}
                <button
                  onClick={handleLogout}
                  className="flex items-center w-full py-3 hover:bg-[#2A2A2A] transition-colors"
                >
                  <Image
                    src="/SignOut-red.png"
                    alt="Log out"
                    width={40}
                    height={40}
                    className="mr-3"
                  />
                  <span className="text-red-700 font-medium text-lg">
                    Log Out
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Change Password Modal */}
      {showPasswordModal && (
        <ChangePasswordModal onClose={() => setShowPasswordModal(false)} />
      )}

      {/* Change Username Modal */}
      {showUsernameModal && (
        <ChangeUsernameModal
          currentUsername={profileData?.username || ""}
          onClose={() => setShowUsernameModal(false)}
        />
      )}

      {/* About Modal removed as it's no longer needed */}
    </>
  );
}
