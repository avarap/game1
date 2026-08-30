class_name LocalizationService
extends RefCounted

const FALLBACK_LOCALE: StringName = &"en"
const SUPPORTED_LOCALES: Array[StringName] = [&"en", &"es"]


static func normalize_locale(locale: String) -> StringName:
	var normalized := locale.strip_edges().to_lower().replace("-", "_")
	var parts := normalized.split("_", false)
	if parts.is_empty():
		return FALLBACK_LOCALE
	return StringName(parts[0])


static func is_supported(locale: String) -> bool:
	return normalize_locale(locale) in SUPPORTED_LOCALES


static func set_locale(locale: String) -> bool:
	var normalized := normalize_locale(locale)
	if normalized not in SUPPORTED_LOCALES:
		return false
	TranslationServer.set_locale(String(normalized))
	return true


static func get_locale() -> StringName:
	return normalize_locale(TranslationServer.get_locale())


static func translate_key(key: StringName) -> String:
	return String(TranslationServer.translate(key))
