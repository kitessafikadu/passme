export const isLocalStorageAvailable = () => {
    if (typeof window === "undefined") return false
  
    try {
      const testKey = "__storage_test__"
      window.localStorage.setItem(testKey, testKey)
      window.localStorage.removeItem(testKey)
      return true
    } catch (e) {
      return false
    }
  }
  
  export const getFromStorage = <T>(key: string, defaultValue: T): T => {
    if (!isLocalStorageAvailable()) return defaultValue;
    
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.error(`Error getting item ${key} from localStorage:`, error);
      return defaultValue;
    }
  };
  
  export const saveToStorage = <T>(key: string, value: T): boolean => {
    if (!isLocalStorageAvailable()) return false;
    
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error(`Error saving item ${key} to localStorage:`, error);
      return false;
    }
  };
  
  export const removeFromStorage = (key: string): boolean => {
    if (!isLocalStorageAvailable()) return false;
    
    try {
      window.localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error(`Error removing item ${key} from localStorage:`, error);
      return false;
    }
  };
  