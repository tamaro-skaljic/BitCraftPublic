// This file and its entire content was copied from BitCraftServer/packages/game/src/i18n.rs to resolve symlinks.
pub const TEMPLATE_SEPARATOR: &str = "|~";
pub const NO_LOCALIZATION_MARKER: &str = "[[NoI18n]]";
pub const SANITIZATION_MARKER: &str = "\u{E000}"; //Guaranteed reserved character

pub fn dont_localize(s: String) -> String {
    return format!("{NO_LOCALIZATION_MARKER}{s}");
}

pub fn dont_reformat(s: String) -> String {
    return s;
}

pub fn is_sanitized(s: &str) -> bool {
    return !s.contains(TEMPLATE_SEPARATOR);
}

pub fn sanitize_string(s: String) -> String {
    return s.replace(SANITIZATION_MARKER, "").replace(TEMPLATE_SEPARATOR, SANITIZATION_MARKER);
}
