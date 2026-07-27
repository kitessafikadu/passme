"use client"
import { useState, useEffect, useRef } from "react"
import ChatBubble, { type ChatItem } from "@/app/components/chatpage/ChatBubble"
import Image from "next/image"
import { useSearchParams } from "next/navigation"
import AudioRecorder from "@/app/components/chatpage/AudioRecorder"
import type { ChatResponse } from "@/app/services/chatApi"

// Storage key that includes the flightId to separate conversations
const getStorageKey = (flightId: string) => `chat_history_${flightId || "default"}`

export default function ChatPage() {
  const searchParams = useSearchParams()
  const flightId = searchParams.get("flightId") ?? ""

  const [chatData, setChatData] = useState<ChatItem[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [isStorageLoaded, setIsStorageLoaded] = useState(false)

  const messagesEndRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  // Load chat history from localStorage on initial mount
  useEffect(() => {
    try {
      const storageKey = getStorageKey(flightId)
      const savedChat = localStorage.getItem(storageKey)

      if (savedChat) {
        const parsedChat = JSON.parse(savedChat) as ChatItem[]
        setChatData(parsedChat)
      }
    } catch (error) {
      console.error("Error loading chat from localStorage:", error)
    } finally {
      setIsStorageLoaded(true)
    }
  }, [flightId])

  // Save chat history to localStorage whenever it changes
  useEffect(() => {
    if (isStorageLoaded && chatData.length > 0) {
      try {
        const storageKey = getStorageKey(flightId)
        localStorage.setItem(storageKey, JSON.stringify(chatData))
      } catch (error) {
        console.error("Error saving chat to localStorage:", error)
      }
    }
  }, [chatData, isStorageLoaded, flightId])

  // Scroll to bottom when chat data changes or loading state changes
  useEffect(() => {
    scrollToBottom()
  }, [chatData, isLoading])

  const handleNewReply = (resp: ChatResponse) => {
    console.log("resp", resp)
    const baseId = chatData.length > 0 ? Math.max(...chatData.map((item) => item.id)) + 1 : 1

    const items: ChatItem[] = [
      {
        id: baseId,
        role: "question",
        text: resp.question.main,
        translation: resp.question.translated,
      },
      {
        id: baseId + 1,
        role: "answer",
        text: resp.answer.main,
        translation: resp.answer.translation,
        transliteration: resp.answer.pronounciation,
        audio: resp.audio,
      },
    ]
    console.log("items", items)
    setChatData((prev) => [...prev, ...items])
  }

  // Function to clear chat history
  const clearChatHistory = () => {
    setChatData([])
    const storageKey = getStorageKey(flightId)
    localStorage.removeItem(storageKey)
  }

  return (
    <div className="relative flex flex-col min-h-screen bg-[#1C1C1C] text-white">
      <header className="flex items-center justify-between py-4 px-6">
        <Image
          src="/banner.png"
          alt="A2SV Translator Banner"
          width={333}
          height={62}
          className="w-[160px] md:w-[220px] md:h-auto object-contain"
          priority
        />
        {chatData.length > 0 && (
          <button
            onClick={clearChatHistory}
            className="text-xs text-gray-400 hover:text-white transition-colors px-3 py-1 rounded-md hover:bg-gray-800"
          >
            Clear History
          </button>
        )}
      </header>

      <main className="flex-grow px-6 py-4 overflow-auto pb-20">
        {chatData.length > 0 ? (
          <div className="max-w-3xl mx-auto flex flex-col space-y-4">
            {chatData.map((chatItem) => (
              <ChatBubble
                key={chatItem.id}
                chatItem={chatItem}
                isLatest={chatItem.id === Math.max(...chatData.map((item) => item.id))}
              />
            ))}
            {isLoading && (
              <div className="flex items-center content-center p-4">
                <div className="flex mx-auto items-end space-x-1">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div
                      key={i}
                      className="w-1.5 bg-purple-500 rounded-full animate-pulse"
                      style={{
                        height: `${15 + Math.random() * 20}px`,
                        animationDelay: `${i * 0.1}s`,
                        animationDuration: "1s",
                      }}
                    />
                  ))}
                  <div
                    className="w-1.5 h-10 bg-blue-500 rounded-full animate-pulse"
                    style={{ animationDelay: "0.6s" }}
                  />
                  <div
                    className="w-1.5 h-12 bg-blue-400 rounded-full animate-pulse"
                    style={{ animationDelay: "0.7s" }}
                  />
                  <div
                    className="w-1.5 h-8 bg-blue-600 rounded-full animate-pulse"
                    style={{ animationDelay: "0.8s" }}
                  />
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div
                      key={i + 5}
                      className="w-1.5 bg-purple-500 rounded-full animate-pulse"
                      style={{
                        height: `${15 + Math.random() * 20}px`,
                        animationDelay: `${(i + 5) * 0.1}s`,
                        animationDuration: "1s",
                      }}
                    />
                  ))}
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>
        ) : (
          <div className="flex mt-[30%] md:mt-[15%] flex-col items-center justify-center">
            {isLoading ? (
              <div className="flex items-center content-center p-4">
                <div className="flex mx-auto items-end space-x-1">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div
                      key={i}
                      className="w-1.5 bg-purple-500 rounded-full animate-pulse"
                      style={{
                        height: `${15 + Math.random() * 20}px`,
                        animationDelay: `${i * 0.1}s`,
                        animationDuration: "1s",
                      }}
                    />
                  ))}
                  <div
                    className="w-1.5 h-10 bg-blue-500 rounded-full animate-pulse"
                    style={{ animationDelay: "0.6s" }}
                  />
                  <div
                    className="w-1.5 h-12 bg-blue-400 rounded-full animate-pulse"
                    style={{ animationDelay: "0.7s" }}
                  />
                  <div
                    className="w-1.5 h-8 bg-blue-600 rounded-full animate-pulse"
                    style={{ animationDelay: "0.8s" }}
                  />
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div
                      key={i + 5}
                      className="w-1.5 bg-purple-500 rounded-full animate-pulse"
                      style={{
                        height: `${15 + Math.random() * 20}px`,
                        animationDelay: `${(i + 5) * 0.1}s`,
                        animationDuration: "1s",
                      }}
                    />
                  ))}
                </div>
              </div>
            ) : (
              <>
                <div className="relative overflow-hidden w-[48px] h-[48px] rounded-[8px] mb-8">
                  <Image
                    src="/messages.png"
                    alt="Messages icon"
                    width={48}
                    height={48}
                    className="object-cover"
                    style={{ filter: "brightness(0) invert(1)" }}
                  />
                </div>
                <p className="text-white align-center text-center max-w-[617px] text-[15px] md:text-[18px]">
                  When you're ready, tap Record to capture the question you'll ask, tap Record again to stop and
                  retrieve the AI's answer, then confidently record your own response to that generated reply.
                </p>
              </>
            )}
          </div>
        )}
      </main>

      <AudioRecorder flightId={flightId} onNewReply={handleNewReply} setIsLoading={setIsLoading} />
    </div>
  )
}
