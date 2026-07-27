import type React from "react";
import Sidebar from "@/app/components/sidebar/sidebar";

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen flex-col md:flex-row md:overflow-hidden relative">
      <Sidebar/>
      <div
        id="main-content"
        className="flex-grow md:overflow-y-auto transition-all duration-300 ease-in-out md:ml-[422px]"
      >
        {children}
      </div>
    </div>
  );
}
