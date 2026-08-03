import { Suspense } from "react";
import ChatPage from "@/app/components/chatpage/ChatPage";

export default async function Page() {
  return (
    <Suspense fallback={null}>
      <ChatPage />
    </Suspense>
  );
}
