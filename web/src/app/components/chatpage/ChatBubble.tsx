"use client"
import { useState, useEffect } from "react"
import type React from "react"

import { useSendManualAnswerMutation } from "@/app/services/manualChatApi"
import { Send, Volume2, Check, X, Edit2 } from "lucide-react"

export interface ChatItem {
  id: number
  role: "question" | "answer"
  text: string
  translation: string
  transliteration?: string
  audio?: string
}

interface ChatBubbleProps {
  chatItem: ChatItem
  isLatest?: boolean
}

const ChatBubble: React.FC<ChatBubbleProps> = ({ chatItem, isLatest = false }) => {
  const isQuestion = chatItem.role === "question"

  const [approved, setApproved] = useState(!isLatest)
  const [isEditing, setIsEditing] = useState(false)
  const [customAnswer, setCustomAnswer] = useState("")

  const [userAnswer, setUserAnswer] = useState<string | null>(null)
  const [translatedAnswer, setTranslatedAnswer] = useState<string>(chatItem.translation || "")
  const [pronounciationAnswer, setPronounciationAnswer] = useState<string>("")

  const [audioUrl, setAudioUrl] = useState<string | null>(null)
  const [customAudioUrl, setCustomAudioUrl] = useState<string | null>(null)
  const [isPlaying, setIsPlaying] = useState(false)
  const [audioElement, setAudioElement] = useState<HTMLAudioElement | null>(null)

  const [sendManualAnswer, { isLoading: isTranslating }] = useSendManualAnswerMutation()

  useEffect(() => {
    if (chatItem.audio && !userAnswer) {
      convertBase64ToBlob(chatItem.audio)
    }
    return () => {
      if (audioUrl) {
        URL.revokeObjectURL(audioUrl)
      }
      if (customAudioUrl) {
        URL.revokeObjectURL(customAudioUrl)
      }
      if (audioElement) {
        audioElement.pause()
        audioElement.src = ""
      }
    }
  }, [chatItem.audio])

  const convertBase64ToBlob = (base64: string, setAsCustom = false) => {
    try {
      const base64ToBlob = (base64Data: string, mimeType = "audio/mp3") => {
        const byteCharacters = atob(base64Data)
        const byteArrays = []

        for (let offset = 0; offset < byteCharacters.length; offset += 512) {
          const slice = byteCharacters.slice(offset, offset + 512)

          const byteNumbers = new Array(slice.length)
          for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i)
          }

          const byteArray = new Uint8Array(byteNumbers)
          byteArrays.push(byteArray)
        }

        return new Blob(byteArrays, { type: mimeType })
      }

      const base64Data = base64.includes("base64,") ? base64.split("base64,")[1] : base64

      const blob = base64ToBlob(base64Data)
      const url = URL.createObjectURL(blob)

      if (setAsCustom) {
        setCustomAudioUrl(url)
      } else {
        setAudioUrl(url)
      }

      if (audioElement) {
        audioElement.src = url
      } else {
        const audio = new Audio(url)
        audio.onended = () => setIsPlaying(false)
        setAudioElement(audio)
      }

      return url
    } catch (error) {
      console.error("Error converting base64 to blob:", error)
      return null
    }
  }

  const handlePlayAudio = () => {
    const currentAudioUrl = userAnswer ? customAudioUrl : audioUrl

    if (!audioElement || !currentAudioUrl) return

    if (audioElement.src !== currentAudioUrl) {
      audioElement.src = currentAudioUrl
    }

    if (isPlaying) {
      audioElement.pause()
      setIsPlaying(false)
    } else {
      audioElement.play().catch((err) => {
        console.error("Error playing audio:", err)
      })
      setIsPlaying(true)
    }
  }

  const handleApprove = () => {
    setApproved(true)
  }

  const handleReject = () => {
    setIsEditing(true)
  }

  const handleSubmitCustom = async () => {
    const input = customAnswer.trim()
    if (!input) return

    try {
      const response = await sendManualAnswer(input).unwrap()
      setUserAnswer(input)
      setTranslatedAnswer(response.translation)
      setPronounciationAnswer(response.pronunciation)

      if (response.audio) {
        convertBase64ToBlob(response.audio, true)
      }

      setApproved(true)
      console.log("Received response:", response)
    } catch (err) {
      console.error("Error translating custom answer:", err)
    } finally {
      setIsEditing(false)
      setCustomAnswer("")
    }
  }

  const mainText = isQuestion ? chatItem.text : (userAnswer ?? chatItem.text)
  const translationText = isQuestion ? chatItem.translation : translatedAnswer

  const shouldShowAudio = approved && !isQuestion && (audioUrl || customAudioUrl)

  return (
    <div
      className={`flex flex-col max-w-md ${isQuestion ? "self-start" : `self-end ${isEditing && "border border-white rounded-lg"}`} `}
    >
      <div
        className={`${isEditing ? "rounded-t-lg" : "rounded-lg"} px-4 py-3 min-w-[250px] ${!isQuestion ? (isEditing ? "bg-[#4D65FF]" : "bg-[#323232]  ") : "bg-[#26252A]"} text-sm relative`}
      >
        <span className={`text-sm mb-1 ${isQuestion ? "text-gray-400" : "text-green-100"}`}>
          {isQuestion ? "Question:" : "Answer:"}
        </span>
        <p className="whitespace-pre-wrap">{mainText}</p>

        {translationText && (
          <div className="mt-2 text-blue-50">
            <strong>{isQuestion ? "Translation:" : "Translation:"}</strong>
            <p>{translationText}</p>
          </div>
        )}

        {approved && !isQuestion && (pronounciationAnswer || chatItem.transliteration) && (
          <div className="mt-2 text-blue-50">
            <strong>Say:</strong>
            <p>{pronounciationAnswer || chatItem.transliteration}</p>
          </div>
        )}

        {shouldShowAudio && (
          <div className="mt-2 flex items-center gap-2">
            <button
              onClick={handlePlayAudio}
              className="flex items-center gap-1 bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded-md text-sm transition-colors duration-200"
            >
              <Volume2 size={16} />
              {isPlaying ? "Pause" : "Play Audio"}
            </button>
          </div>
        )}
      </div>

      {isEditing && (
        <div className="w-full">
          <div className="bg-[#1E1E1E] rounded-b-lg flex items-center p-2">
            <input
              className="flex-1 bg-transparent border-none outline-none text-white px-3 py-2"
              value={customAnswer}
              onChange={(e) => setCustomAnswer(e.target.value)}
              placeholder="Type your desired answer..."
            />
            <button
              onClick={handleSubmitCustom}
              disabled={isTranslating || !customAnswer.trim()}
              className="bg-blue-600 text-white p-2 rounded-full disabled:opacity-50 disabled:cursor-not-allowed hover:bg-blue-700 transition-colors duration-200"
              title="Send answer"
            >
              <Send size={20} />
            </button>
          </div>
        </div>
      )}

      {isLatest && !approved && !isEditing && (
        <div className="flex justify-center items-center gap-4 mt-3 animate-fadeIn">
          <div className="relative group">
            <button
              onClick={handleApprove}
              title="Approve Answer"
              className="flex items-center justify-center w-12 h-12 bg-emerald-500 hover:bg-emerald-600 text-white rounded-full shadow-lg transform transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-emerald-400 focus:ring-opacity-50"
              aria-label="Approve Answer"
            >
              <Check size={24} />
            </button>
            <span className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 whitespace-nowrap">
              Approve
            </span>
          </div>

          {/* <div className="relative group">
            <button
              onClick={handleReject}
              title="Edit Answer"
              className="flex items-center justify-center w-12 h-12 bg-blue-500 hover:bg-blue-600 text-white rounded-full shadow-lg transform transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-50"
              aria-label="Edit Answer"
            >
              <Edit2 size={20} />
            </button>
            <span className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 whitespace-nowrap">
              Edit
            </span>
          </div> */}

          <div className="relative group">
            <button
              onClick={handleReject}
              title="Reject Answer"
              className="flex items-center justify-center w-12 h-12 bg-rose-500 hover:bg-rose-600 text-white rounded-full shadow-lg transform transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-rose-400 focus:ring-opacity-50"
              aria-label="Reject Answer"
            >
              <X size={24} />
            </button>
            <span className="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 whitespace-nowrap">
              Reject
            </span>
          </div>
        </div>
      )}
    </div>
  )
}

export default ChatBubble
