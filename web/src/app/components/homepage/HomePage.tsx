"use client";
import Image from "next/image";
import { useState, useEffect } from "react";
import FormContainer from "../auth/FormContainer";

export default function HomePage() {
  return (
    <div className="px-5 bg-[linear-gradient(46deg,rgba(33,33,33,0.84)_0%,rgba(66,66,66,0.24)_178.98%),url('/background.jpg')] bg-cover bg-center w-full h-screen flex flex-col md:flex-row justify-center item-center gap-20">
      <Banner />
      <div className="bg-zinc-50 max-w-90 md:w-90 min-w-80 min-h-[90%] h-170 mt-auto mb-2 rounded-t-2xl mx-auto">
        <FormContainer />
      </div>
    </div>
  );
}

function Banner() {
  const messages = [
    {
      title: "Building the Future...",
      msg: "Translate anything, anytime, with ease. A2SV Translator breaks language barriers. Making communication smooth, fast, and accessible for everyone.",
    },
    {
      title: "Building the Future...",
      msg: "Another inspiring message about innovation and connectivity.",
    },
    {
      title: "Building the Future...",
      msg: "One more message to showcase our carousel effect.",
    },
  ];

  const [currentIndex, setCurrentIndex] = useState(0);
  const [fade, setFade] = useState(true);

  useEffect(() => {
    const interval = setInterval(() => {
      setFade(false);
      setTimeout(() => {
        setCurrentIndex((prevIndex) => (prevIndex + 1) % messages.length);
        setFade(true);
      }, 500);
    }, 3000);

    return () => clearInterval(interval);
  }, [messages.length]);

  return (
    <div className="relative overflow-hidden flex flex-col items-center justify-center text-white h-full">
      <Image
        src="/banner.png"
        alt="A2SV Translator Banner"
        width={200}
        height={100}
        className="md:w-100 h-auto object-fit"
        priority
      />

      <div
        className={`w-150 relative z-10 flex flex-col items-center text-center px-8`}
      >
        <div
          className={`w-[70%] m-auto text-lg md:text-2xl transition-opacity duration-500 ${
            fade ? "opacity-100" : "opacity-0"
          }`}
        >
          <div className="min-h-40">
            <h1 className="text-md md:text-4xl font-bold mb-6 text-left">
              {messages[currentIndex].title}
            </h1>
            <pre className="whitespace-pre-line opacity-80 text-left text-[18px]">
              {messages[currentIndex].msg}
            </pre>
          </div>
          <div className="flex gap-2 mt-6 self-start">
            {messages.map((_, index) => (
              <svg
                key={index}
                xmlns="http://www.w3.org/2000/svg"
                width={index === currentIndex ? 48 : 32}
                height="6"
                viewBox={`0 0 ${index === currentIndex ? 48 : 32} 6`}
                fill="none"
              >
                <path
                  d={`M0 3H${index === currentIndex ? 48 : 32}`}
                  stroke={index === currentIndex ? "white" : "#9E9E9E"}
                  strokeWidth={index === currentIndex ? 5 : 2}
                />
              </svg>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
