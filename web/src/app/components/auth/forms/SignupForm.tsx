"use client";
import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { useRegisterMutation } from "@/app/services/authApi";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";

interface FormValues {
  fullName: string;
  email:    string;
  password: string;
}

const SignupForm: React.FC = () => {
  const router = useRouter();
  const [registerUser, { isLoading: isRegistering }] = useRegisterMutation();
  const [authError, setAuthError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>();

  const onSubmit = async (data: FormValues) => {
    setAuthError(null);

    try {
      const res = await registerUser({
        username:     data.fullName,
        email:    data.email,
        password: data.password,
      }).unwrap();

      const signin = await signIn("credentials", {
        redirect: false,
        email:    data.email,
        password: data.password,
      });

      if (signin?.error) {
        setAuthError(signin.error);
      } else {
        router.push("/dashboard");
      }
    } catch (e: any) {
      setAuthError(e.data?.message || e.message || "Registration failed");
    }
  };

  return (
    <div className="w-full">
      <div className="mb-6">
        <p className="text-[13px]">LET&#39;S GET STARTED</p>
        <p className="font-bold text-[25px]">Create an Account</p>
      </div>

      <form
        className="flex flex-col w-full max-w-md"
        onSubmit={handleSubmit(onSubmit)}
        noValidate
      >
        {/* Name */}
        <div className="mb-5 relative group">
          <input
            type="text"
            {...register("fullName", {
              required: "Name is required",
            })}
            placeholder="John Doe"
            className="w-full h-12 px-3 py-2 border border-violet-200 hover:border-[#424242] rounded-md opacity-70 placeholder:text-sm focus:outline-none"
          />
          <label className="absolute -top-3 left-3 bg-white px-2 text-sm text-[#BDBDBD] group-hover:text-[#424242]">
            Your Name
          </label>
          {errors.fullName && (
            <p className="text-red-500 text-xs absolute top-full right-0 mt-1">
              {errors.fullName.message}
            </p>
          )}
        </div>

        {/* Email */}
        <div className="mb-5 relative group">
          <input
            type="email"
            {...register("email", {
              required: "Email is required",
              pattern: {
                value:
                  /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
                message: "Invalid email format",
              },
            })}
            placeholder="you@example.com"
            className="w-full h-12 px-3 py-2 border border-[#BDBDBD] hover:border-[#424242] rounded-md opacity-70 placeholder:text-sm focus:outline-none"
          />
          <label className="absolute -top-3 left-3 bg-white px-2 text-sm text-[#BDBDBD] group-hover:text-[#424242]">
            Email
          </label>
          {errors.email && (
            <p className="text-red-500 text-xs absolute top-full right-0 mt-1">
              {errors.email.message}
            </p>
          )}
        </div>

        {/* Password */}
        <div className="mb-5 relative group">
          <input
            type={showPassword ? "text" : "password"}
            {...register("password", {
              required: "Password is required",
            })}
            placeholder="••••••••"
            className="w-full h-12 px-3 py-2 border border-violet-200 hover:border-[#424242] rounded-md opacity-70 placeholder:text-sm focus:outline-none"
          />
          <label className="absolute -top-3 left-3 bg-white px-2 text-sm text-[#BDBDBD] group-hover:text-[#424242]">
            Password
          </label>
          <button
            type="button"
            onClick={() => setShowPassword((p) => !p)}
            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-[#BDBDBD] group-hover:text-[#424242]"
          >
            {showPassword ? (
              /* eye open */
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
            ) : (
              /* eye closed */
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7
                     a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M9.878 9.878l4.242 4.242M3 3l18 18" />
              </svg>
            )}
          </button>
          {errors.password && (
            <p className="text-red-500 text-xs absolute top-full right-0 mt-1">
              {errors.password.message}
            </p>
          )}
        </div>

        {authError && (
          <p className="text-red-600 mb-4 text-center">{authError}</p>
        )}

        <button
          type="submit"
          disabled={isRegistering}
          className="text-[13px] h-12 w-full bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
        >
          {isRegistering ? "CREATIGN ACCOUNT ...." : "GET STARTED"}
        </button>
      </form>
    </div>
  );
};

export default SignupForm;
