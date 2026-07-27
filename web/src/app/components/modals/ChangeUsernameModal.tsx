"use client";

import type React from "react";
import { useState } from "react";
import { useUpdateUsernameMutation } from "../../services/profileApi";

interface ChangeUsernameModalProps {
  currentUsername: string;
  onClose: () => void;
}

export default function ChangeUsernameModal({
  currentUsername,
  onClose,
}: ChangeUsernameModalProps) {
  const [newUsername, setNewUsername] = useState(currentUsername);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [updateUsername, { isLoading }] = useUpdateUsernameMutation();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!newUsername.trim()) {
      setError("Username cannot be empty");
      return;
    }

    try {
      const result = await updateUsername({
        new_username: newUsername,
      }).unwrap();

      setSuccess(result.message || "Username updated successfully");

      // Close modal after 2 seconds
      setTimeout(() => {
        onClose();
      }, 2000);
    } catch (err: any) {
      setError(err.data?.message || "Failed to update username");
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="inline-flex flex-col items-start gap-[10px] p-[40px] rounded-[12px] bg-[#202020] text-white w-full max-w-md relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-white"
          aria-label="Close"
        >
          ✕
        </button>

        <h2 className="text-xl font-bold mb-4">Change Username</h2>

        {error && (
          <div className="p-3 text-sm text-white bg-red-500 rounded w-full mb-4">
            {error}
          </div>
        )}
        {success && (
          <div className="p-3 text-sm text-white bg-green-500 rounded w-full mb-4">
            {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="w-full space-y-4">
          <div>
            <label
              htmlFor="new-username"
              className="block text-sm font-medium text-gray-300 mb-1"
            >
              New Username
            </label>
            <input
              id="new-username"
              type="text"
              value={newUsername}
              onChange={(e) => setNewUsername(e.target.value)}
              required
              className="w-full px-3 py-2 text-white bg-gray-800 border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div className="flex justify-end pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 mr-2 text-white bg-gray-600 rounded-md hover:bg-gray-700"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {isLoading ? "Updating..." : "Update Username"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
