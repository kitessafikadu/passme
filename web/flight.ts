export type TranslationKeys = {
  flightDetails: string;
  flightName: string;
  flightNamePlaceholder: string;
  flightNameRequired: string;
  flightNamePattern: string;
  fromCountry: string;
  fromCountryPlaceholder: string;
  fromCountryRequired: string;
  toCountry: string;
  toCountryPlaceholder: string;
  toCountryRequired: string;
  flightDate: string;
  flightDatePlaceholder: string;
  flightDateRequired: string;
  commonQuestions: string;
  submitButton: string;
    confirmationQuestion:string;
    backToEdit:string,
    confirmYes:string,
    validation:any
};

export type Translations = {
  english: TranslationKeys;
  amharic: TranslationKeys;
  turkish: TranslationKeys;
};
const  flight= {
    "english": {
      "flightDetails": "Flight Details",
      "flightName": "Flight name",
      "flightNamePlaceholder": "Your flight name",
      "flightNameRequired": "Flight name is required",
      "flightNamePattern": "Please use English letters only",
      "fromCountry": "From Country",
      "fromCountryPlaceholder": "Your origin country",
      "fromCountryRequired": "Flight origin is required",
      "toCountry": "To Country",
      "toCountryPlaceholder": "Your destination country",
      "toCountryRequired": "Flight destination is required",
      "flightDate": "Flight date",
      "flightDatePlaceholder": "Set your flight time and date",
      "flightDateRequired": "Flight date is required",
      "commonQuestions": "Common Airport Questions",
      "submitButton": "Submit",
    "confirmationQuestion": "Are you sure you want to continue with this information?",
    "backToEdit": "Back to Edit",
    "confirmYes": "YES",
    "validation": {
      "Required": "This field is required",
      "LettersOnly": "Please use English letters only",
      "pattern": "^[a-zA-Z\\s]+$"
    },
  },
    "amharic": {
      "flightDetails": "የበረራ ዝርዝሮች",
      "flightName": "የበረራ ስም",
      "flightNamePlaceholder": "የበረራ ስም",
      "flightNameRequired": "የበረራ ስም አስፈላጊ ነው።",
      "flightNamePattern": "እባኮትን የአማርኛ ፊደል ብቻ ያስገቡ።",
      "fromCountry": "መነሻ አገር",
      "fromCountryPlaceholder": "የመነሻ አገር",
      "fromCountryRequired": "መነሻ አገር አስፈላጊ ነው።",
      "toCountry": "መድረሻ አገር",
      "toCountryPlaceholder": "የመድረሻ አገር",
      "toCountryRequired": "መድረሻ አገር አስፈላጊ ነው።",
      "flightDate": "የበረራ ቀን",
      "flightDatePlaceholder": "የበረራዎን ቀን እና ሰዓት ይመርጡ",
      "flightDateRequired": "የበረራ ቀን አስፈላጊ ነው።",
      "commonQuestions": "በአየር ማረፊያ በተደጋጋሚ የሚጠየቁ ጥያቄዎች",
      "submitButton": "አስገባው",
    "confirmationQuestion": "እርግጠኛ ነህ/ነሽ ይህን መረጃ ማስቀመጥ ይፈልጋሉ?",
    "backToEdit": "ወደ ማረም ተመለስ",
    "confirmYes": "አዎ",
    "validation": {
      "Required": "ይህ መስክ አስፈላጊ ነው",
      "LettersOnly": "እባኮትን የአማርኛ ፊደል ብቻ ያስገቡ።",
      "pattern": "^[\\u1200-\\u137F\\s]+$"

    }
    },
    "turkish": {
      "flightDetails": "Uçuş Detayları",
      "flightName": "Uçuş Adı",
      "flightNamePlaceholder": "Uçuş adınız",
      "flightNameRequired": "Uçuş adı zorunludur",
      "flightNamePattern": "Lütfen yalnızca İngilizce harfler kullanın",
      "fromCountry": "Kalkış Ülkesi",
      "fromCountryPlaceholder": "Kalkış ülkeniz",
      "fromCountryRequired": "Kalkış ülkesi zorunludur",
      "toCountry": "Varış Ülkesi",
      "toCountryPlaceholder": "Varış ülkeniz",
      "toCountryRequired": "Varış ülkesi zorunludur",
      "flightDate": "Uçuş Tarihi",
      "flightDatePlaceholder": "Uçuş tarih ve saatinizi ayarlayın",
      "flightDateRequired": "Uçuş tarihi zorunludur",
      "commonQuestions": "Havalimanında sık sorulan sorular",
      "submitButton": "Gönder",
    "confirmationQuestion": "Bu bilgilerle devam etmek istediğinizden emin misiniz?",
    "backToEdit": "Düzenlemeye Dön",
    "confirmYes": "EVET",
    "validation": {
      "Required": "Bu alan zorunludur",
      "LettersOnly": "Lütfen yalnızca Türkçe karakterler kullanın",
      "pattern": "^[a-zA-ZçÇğĞıİöÖşŞüÜ\\s]+$"
    }
  }
  }
  export default flight;