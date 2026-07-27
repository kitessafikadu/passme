"use client"
import { useState, useRef, useEffect } from "react"
import type React from "react"

import Image from "next/image"
import { useSendAudioChatMutation, type ChatResponse } from "@/app/services/chatApi"
import ErrorMessage from "./ErrorMessage"

interface AudioRecorderProps {
  flightId: string
  onNewReply: (reply: ChatResponse) => void
  setIsLoading: (isLoading: boolean) => void
}

const AudioRecorder: React.FC<AudioRecorderProps> = ({ flightId, onNewReply, setIsLoading }) => {
  const [recording, setRecording] = useState(false)
  const [audioURL, setAudioURL] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const mediaRecorderRef = useRef<MediaRecorder | null>(null)
  const audioChunksRef = useRef<Blob[]>([])
  const [sendAudioChat, { isLoading: isSending }] = useSendAudioChatMutation()

  useEffect(() => {
    setIsLoading(isSending)
  }, [isSending, setIsLoading])

  const startRecording = async () => {
    setError(null)
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      const mediaRecorder = new MediaRecorder(stream)
      mediaRecorderRef.current = mediaRecorder
      audioChunksRef.current = []

      mediaRecorder.ondataavailable = (event: BlobEvent) => {
        if (event.data.size > 0) audioChunksRef.current.push(event.data)
      }

      mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(audioChunksRef.current, {
          type: "audio/wav",
        })
        console.log(audioBlob)
        const file = new File([audioBlob], "recording.wav", {
          type: "audio/wav",
        })
        setAudioURL(URL.createObjectURL(audioBlob))
        try {
          const response = await sendAudioChat({ flightId, file }).unwrap()
          onNewReply(response)
        } catch (err) {
          setError("We couldn't process your audio. Please try recording again.")
        }
      }

      mediaRecorder.start()
      setRecording(true)
    } catch (err) {
      console.error("Error starting recording:", err)
      setError("Could not access your microphone. Please check your permissions and try again.")
    }
  }

  const stopRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== "inactive") {
      mediaRecorderRef.current.stop()
      setRecording(false)
    }
  }

  const dismissError = () => {
    setError(null)
  }

  const retryRecording = () => {
    setError(null)
    startRecording()
  }

  return (
    <>
      <footer className="flex items-center justify-center sticky bottom-5 w-full bg-[#1C1C1C] z-10">
        {error && <ErrorMessage message={error} onDismiss={dismissError} onRetry={retryRecording} />}
        <button
          onClick={() => (recording ? stopRecording() : startRecording())}
          disabled={isSending}
          className={`flex items-center justify-center bg-blue-600 hover:bg-blue-700 text-white rounded-full px-6 py-2 transition ${
            recording ? "animate-pulse border-4 border-blue-400" : ""
          }`}
        >
          <Image src="/mic.svg" alt="Mic" height={30} width={30} />
        </button>
      </footer>
    </>
  )
}

export default AudioRecorder
