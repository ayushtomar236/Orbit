import Foundation
import Supabase

enum SupabaseFactory {
    static let client: SupabaseClient? = {
        guard let url = AppConfig.supabaseURL, let key = AppConfig.supabaseAnonKey else {
            return nil
        }
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: .init(
                db: .init(
                    encoder: JSONCoding.encoder,
                    decoder: JSONCoding.decoder
                )
            )
        )
    }()
}
