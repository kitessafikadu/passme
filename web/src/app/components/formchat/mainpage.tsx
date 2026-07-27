"use client";
import React, { useState } from "react";
import Image from "next/image";
import questions from "../../../../question";
import questionsAmharic from "../../../../amharic";
import FormComponent from "./FormComponent";
// import {inter} from "@/app/libs/font";
// import Link from 'next/link'

const Mainpage = () => {
  const [lanaguage, setLanaguage] = useState("amharic");
  const [toLanguage, setToLanguage] = useState("english");
  const [popup, setPopup] = useState(false);


  const handleLangaugechange = (
    event: React.ChangeEvent<HTMLSelectElement>
  ) => {
    const selectedLanguage = event.target.value;
    setLanaguage(selectedLanguage);
    setToLanguage(selectedLanguage === "english" ? "amharic" : "english");
  };
  const handletoLangaugechange = (
    event: React.ChangeEvent<HTMLSelectElement>
  ) => {
    const toLanguage = event.target.value;
    setToLanguage(toLanguage);
    setLanaguage(toLanguage === "english" ? "amharic" : "english");
  };
  const handleedit = () => {
    setPopup(false);
  };
  const handlethepopup = () => {
    setPopup(!popup);
  };

  return (
    <div className={`w-full h-full bg-[#1C1C1C] overflow-scroll`}>
      <div className="w-full ">
        <div>
          {/* Banner at the top, horizontally centered */}
          <div className=" flex justify-center items-center   py-4">
            <div>
              <Image
                src="/banner.png"
                alt="A2SV Translator Banner"
                width={333}
                height={62}
                className="w-[180px] md:w-[220px] md:h-auto object-contain"
                priority
              />
            </div>
          </div>

        </div>
      </div>

      <div className="flex mx-10 justify-around mt-5">
        <div className="lex flex-col items-center space-x-">
          <p className="text-white text-[14px]">From:</p>
          <div className="w-full md:w-[280px] h-[56px] rounded-lg pr-4 flex items-center gap-4">
            <select
              title="Select language"
              value={lanaguage}
              onChange={handleLangaugechange}
              className="bg-neutral-500 text-white rounded min-w-30 md:min-w-50 max-w-50 h-10 text-center"
            >
              <option value="english">English</option>
              <option value="amharic">Amharic</option>
              <option value="turkish">Turkish</option>
            </select>
          </div>
        </div>

        <div>
          <p className="text-white text-[14px]">To:</p>
          <div className="w-full md:w-[280px] h-[56px] rounded-lg pr-4 flex items-center gap-4">
            <select
              className="bg-neutral-500 text-white rounded min-w-30 md:min-w-50 max-w-50 h-10 text-center"
              value={toLanguage}
              onChange={handletoLangaugechange} >
              <option value="english">English</option>
            </select>
          </div>
        </div>
      </div>

      <FormComponent
        key={lanaguage}
        setPopup={setPopup}
        lanaguage={lanaguage}
        questions={questions}
        questionsAmharic={questionsAmharic}
        popup={popup}
        handlethepop={handlethepopup}
        handleedit={handleedit}
      />
    </div>
  );
};

export default Mainpage;
