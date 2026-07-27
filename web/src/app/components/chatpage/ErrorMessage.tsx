"use client"

import type React from "react"

import { XCircle } from "lucide-react"
import { useState, useEffect } from "react"

interface ErrorMessageProps {
  message: string
  onDismiss: () => void
  onRetry: () => void
}

const ErrorMessage: React.FC<ErrorMessageProps> = ({ message, onDismiss, onRetry }) => {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    // Animate in
    setIsVisible(true)

    // Auto-dismiss after 10 seconds
    const timer = setTimeout(() => {
      setIsVisible(false)
      setTimeout(onDismiss, 300) // Wait for animation to complete
    }, 10000)

    return () => clearTimeout(timer)
  }, [onDismiss])

  return (
    <div
      className={`absolute left-0 right-0 mx-auto bottom-20 bg-red-900/90 backdrop-blur-sm text-white rounded-lg shadow-lg p-4 max-w-sm w-[90%] transition-all duration-300 ${
        isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
      }`}
    >
      <div className="flex items-start">
        <div className="flex-shrink-0">
          <XCircle className="h-5 w-5 text-red-400" />
        </div>
        <div className="ml-3 flex-1">
          <p className="text-sm font-medium">{message}</p>
          <div className="mt-3 flex gap-3">
            <button
              onClick={() => {
                setIsVisible(false)
                setTimeout(onRetry, 300)
              }}
              className="bg-red-700 hover:bg-red-600 text-white text-xs px-3 py-1.5 rounded-md transition-colors"
            >
              Try Again
            </button>
            <button
              onClick={() => {
                setIsVisible(false)
                setTimeout(onDismiss, 300)
              }}
              className="bg-transparent border border-red-700 hover:bg-red-800/30 text-white text-xs px-3 py-1.5 rounded-md transition-colors"
            >
              Dismiss
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ErrorMessage
