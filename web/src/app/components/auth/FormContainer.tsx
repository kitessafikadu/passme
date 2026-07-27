"use client";

import { useState } from "react";
import Image from "next/image";
import LoginForm from "./forms/LoginForm";
import SignupForm from "./forms/SignupForm";

interface FormContainerProps {
  initialType?: "login" | "signup";
}

const FormContainer = ({ initialType = "login" }: FormContainerProps) => {
  const [formType, setFormType] = useState<"login" | "signup">(initialType);

  const toggleForm = () => {
    setFormType((prev) => (prev === "login" ? "signup" : "login"));
  };

  return (
    <div className="max-w-md mx-auto p-8 w-full flex flex-col">
      {/* Display the login or signup form based on formType */}
      <div
        className={`relative transition-[min-height] duration-500 ease-in-out ${formType === "login" ? "min-h-[280px]" : "min-h-[300px]"
          }`}
      >
        <div
          className={`absolute top-0 left-0 w-full transition-all duration-500 ease-in-out
        ${formType === "login" ? "opacity-100 translate-x-0 pointer-events-auto" : "opacity-0 -translate-x-10 pointer-events-none"}`}
        >
          <LoginForm />
        </div>

        <div
          className={`absolute top-0 left-0 w-full transition-all duration-500 ease-in-out
        ${formType === "signup" ? "opacity-100 translate-x-0 pointer-events-auto" : "opacity-0 translate-x-10 pointer-events-none"}`}
        >
          <SignupForm />
        </div>
      </div>

      {/* Social Buttons and Links */}
      <div className="mt-6">
        {/* Divider */}
        <div className="flex items-center mt-6">
          <div className="flex-grow h-px bg-gray-300"></div>
          <span className="px-4 text-sm text-gray-500">Or</span>
          <div className="flex-grow h-px bg-gray-300"></div>
        </div>

        {/* Social Login Buttons */}
        <div className="flex flex-col justify-between gap-10">
          <div>
            <button className="text-[13px] text-neutral-600 w-full flex items-center justify-center gap-2 border border-zinc-100 py-2 rounded-xl mb-1 hover:bg-gray-50">
              <div className="w-[20%] flex justify-end"><Image src="/google-icon.png" alt="Google" width={20} height={20} className="w-4 h-4" /></div>
              <div className="w-[80%] flex pl-8">{formType === "login" ? "Log in with Google" : "Sign up with Google"}</div>
            </button>

            <button className="text-[13px] text-neutral-600 w-full flex items-center justify-center gap-2 border border-zinc-100 py-2 rounded-full mb-1 hover:bg-gray-50">
              <div className="w-[20%] flex justify-end"><Image src="/facebook-icon.png" alt="Google" width={20} height={20} className="w-3 h-3" /></div>
              <div className="w-[80%] flex pl-8">{formType === "login" ? "Log in with Facebook" : "Sign up with Facebook"}</div>
            </button>

            <button className="text-[13px] text-neutral-600 w-full flex items-center justify-center gap-2 border border-zinc-100 py-2 rounded-full hover:bg-gray-50">
              <div className="w-[20%] flex justify-end"><Image src="/Shape.png" alt="Google" width={20} height={20} className="w-3 h-3" /></div>
              <div className="w-[80%] flex pl-8">{formType === "login" ? "Log in with Apple" : "Sign up with Apple"}</div>
            </button>
          </div>

          {/* Navigation Links */}
          <div>
            {formType === "login" ? (
              <p className="text-[13px] text-center">
                New User?{" "}
                <span
                  onClick={toggleForm}
                  className="text-blue-500 font-bold hover:underline cursor-pointer"
                >
                  SIGNUP HERE
                </span>
              </p>
            ) : (
              <p className="text-[13px] text-center">
                Already have an account?{" "}
                <span
                  onClick={toggleForm}
                  className="text-blue-500 font-bold hover:underline cursor-pointer"
                >
                  LOGIN HERE
                </span>
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default FormContainer;
