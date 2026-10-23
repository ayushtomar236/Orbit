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
            trimmed != "UNSET",
            !trimmed.contains("YOUR_PROJECT"),
            !trimmed.contains("placeholder"),
            let url = URL(string: trimmed),
            url.scheme == "https"
        else { return nil }
        return url
    }

    static var supabaseAnonKey: String? {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        else { return nil }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 20, trimmed != "UNSET" else { return nil }

        // Supabase publishable keys are intended for clients. Legacy anon JWTs are
        // accepted only when their signed payload identifies the anon role. Reject
        // secret keys and service_role JWTs before they reach the mobile client.
        if trimmed.hasPrefix("sb_publishable_") { return trimmed }
        guard legacyJWTRole(in: trimmed) == "anon" else { return nil }
        return trimmed
    }

    private static func legacyJWTRole(in token: String) -> String? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var payload = String(parts[1]).replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count.isMultiple(of: 4) == false { payload.append("=") }
        guard
            let data = Data(base64Encoded: payload),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return object["role"] as? String
    }
}
