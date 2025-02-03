const localizedStrings = {
  en: require("../locales/en.json"),
  fr: require("../locales/fr.json"),
};

function getLocalizedString(language, key) {
  return localizedStrings[language]?.[key] || localizedStrings["en"][key];
}

module.exports = {getLocalizedString};
