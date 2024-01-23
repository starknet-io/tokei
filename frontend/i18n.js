// i18n.js
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Language resources (translations) - you can structure these as needed
const resources = {
    en: {
        translation: {
            // Your English translations here
        },
    },
    // Add translations for other languages as needed
};

i18n
    .use(initReactI18next)
    .init({
        resources,
        lng: 'en', // Default language
        fallbackLng: 'en', // Fallback language if a translation is missing
        interpolation: {
            escapeValue: false, // React already escapes variables
        },
    });

export default i18n;
