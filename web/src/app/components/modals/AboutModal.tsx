"use client";

interface AboutModalProps {
  aboutText: string;
  onClose: () => void;
}

export default function AboutModal({ aboutText, onClose }: AboutModalProps) {
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

        <h2 className="text-xl font-bold mb-4">About</h2>

        <div className="w-full p-4 bg-gray-800 rounded-md">
          <p>{aboutText}</p>
        </div>

        <div className="flex justify-end w-full pt-4">
          <button
            onClick={onClose}
            className="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
