import Foundation

/// Compile-time secrets for WYA cloud services.
/// ⚠️  Replace placeholder values before shipping.
///     Never commit real secrets to source control —
///     use Xcode build settings or a CI secrets manager instead.
enum Secrets {
    /// Base URL of the deployed Cloudflare Worker.
    /// Example: "https://wya-api.<your-subdomain>.workers.dev"
    static let cloudBaseURL: String = {
        // Read from build setting injected via xcconfig / CI, fall back to placeholder.
        if let value = Bundle.main.object(forInfoDictionaryKey: "WYA_CLOUD_BASE_URL") as? String,
           !value.isEmpty, value != "$(WYA_CLOUD_BASE_URL)" {
            return value
        }
        return "https://wya-api.example.workers.dev"  // ← replace in xcconfig
    }()

    /// Bearer token / API secret used to authenticate requests to the Worker.
    static let apiSecret: String = {
        if let value = Bundle.main.object(forInfoDictionaryKey: "WYA_API_SECRET") as? String,
           !value.isEmpty, value != "$(WYA_API_SECRET)" {
            return value
        }
        return "REPLACE_WITH_YOUR_API_SECRET"  // ← replace in xcconfig
    }()
}
