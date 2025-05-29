import Foundation

protocol NutritionCacheServiceInterface {
    func getCachedNutrition(for query: String) -> [Item]?
    func cacheNutrition(_ items: [Item], for query: String)
    func clearCache()
}

class NutritionCacheService: NutritionCacheServiceInterface {
    // Cache configuration
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    // Cache structure to store both data and timestamp
    private class CacheEntry {
        let items: [Item]
        let timestamp: Date
        
        init(items: [Item], timestamp: Date) {
            self.items = items
            self.timestamp = timestamp
        }
        
        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < 3600 // 1 hour validity
        }
    }
    
    // Thread-safe cache dictionary
    private let cache = NSCache<NSString, CacheEntry>()
    
    init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum number of entries
    }
    
    func getCachedNutrition(for query: String) -> [Item]? {
        let normalizedQuery = normalizeQuery(query)
        guard let entry = cache.object(forKey: normalizedQuery as NSString) else {
            return nil
        }
        
        // Return nil if cache entry has expired
        guard entry.isValid else {
            cache.removeObject(forKey: normalizedQuery as NSString)
            return nil
        }
        
        return entry.items
    }
    
    func cacheNutrition(_ items: [Item], for query: String) {
        let normalizedQuery = normalizeQuery(query)
        let entry = CacheEntry(items: items, timestamp: Date())
        cache.setObject(entry, forKey: normalizedQuery as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    // Helper method to normalize queries for consistent cache keys
    private func normalizeQuery(_ query: String) -> String {
        let lowercased = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove specific quantities but keep the unit type
        // Example: "250 grams of chicken breast" -> "grams of chicken breast"
        let quantityPattern = #"\d+\s*"#
        let normalizedQuery = lowercased.replacingOccurrences(
            of: quantityPattern,
            with: "",
            options: .regularExpression
        )
        
        // Remove common filler words
        let fillerWords = ["of", "the", "a", "an"]
        var words = normalizedQuery.components(separatedBy: " ")
        words = words.filter { !fillerWords.contains($0) }
        
        return words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 