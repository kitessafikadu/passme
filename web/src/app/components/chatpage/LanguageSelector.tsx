import React, { useState } from 'react'

interface LanguageSelectorProps {
  label: string
  initialLanguage: string
}

const LanguageSelector: React.FC<LanguageSelectorProps> = ({
  label,
  initialLanguage,
}) => {
  const [language, setLanguage] = useState(initialLanguage)

  return (
    <div className="flex flex-col items-center space-x-2">
      <div className="self-start">{label}:</div>
      <select
        className="bg-neutral-500 text-white rounded min-w-30 md:min-w-50 max-w-50 h-10 text-center"
        value={language}
        onChange={(e) => setLanguage(e.target.value)}
      >
        <option value="English">English</option>
        <option value="Amharic">Amharic</option>
      </select>
    </div>
  )
}

export default LanguageSelector
