import Foundation

enum AppConfig {
    static var isConfigured: Bool {
        supabaseURL != nil && supabaseAnonKey != nil
    }

    static var supabaseURL: URL? {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmed.isEmpty,
            !trimmed.contains("YOUR_PROJECT"),
            !trimmed.contains("placeholder"),
            let url = URL(string: trimmed)
        else { return nil }
        return url
    }

    static var supabaseAnonKey: String? {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        else { return nil }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 20, !trimmed.contains("your-anon-key"), !trimmed.contains("placeholder") else {
            return nil
        }
        return trimmed
    }
}
