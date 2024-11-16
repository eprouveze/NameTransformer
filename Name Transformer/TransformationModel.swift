import Foundation

struct Transformation: Identifiable, Codable {
    let id: UUID
    let original: String
    let transformed: String
    let date: Date
    
    init(original: String, transformed: String) {
        self.id = UUID()
        self.original = original
        self.transformed = transformed
        self.date = Date()
    }
}

class TransformationStore: ObservableObject {
    @Published var favorites: [Transformation] = []
    @Published var history: [Transformation] = []
    
    private let favoritesKey = "favorites"
    private let historyKey = "history"
    private let maxHistoryItems = 50
    
    init() {
        loadFavorites()
        loadHistory()
    }
    
    func addToHistory(_ transformation: Transformation) {
        if !history.contains(where: { 
            $0.original == transformation.original && 
            $0.transformed == transformation.transformed 
        }) {
            history.insert(transformation, at: 0)
            if history.count > maxHistoryItems {
                history.removeLast()
            }
            saveHistory()
        }
    }
    
    func toggleFavorite(_ transformation: Transformation) {
        if let existingIndex = favorites.firstIndex(where: { 
            $0.original == transformation.original && 
            $0.transformed == transformation.transformed 
        }) {
            favorites.remove(at: existingIndex)
        } else {
            favorites.insert(transformation, at: 0)
        }
        saveFavorites()
    }
    
    func isFavorite(_ transformation: Transformation) -> Bool {
        favorites.contains(where: { 
            $0.original == transformation.original && 
            $0.transformed == transformation.transformed 
        })
    }
    
    func removeFromHistory(_ transformation: Transformation) {
        if let index = history.firstIndex(where: { $0.id == transformation.id }) {
            history.remove(at: index)
            if let favIndex = favorites.firstIndex(where: { 
                $0.original == transformation.original && 
                $0.transformed == transformation.transformed 
            }) {
                favorites.remove(at: favIndex)
            }
            saveHistory()
            saveFavorites()
        }
    }
    
    var allHistory: [Transformation] {
        history
    }
    
    func removeAllHistory() {
        history.removeAll()
        favorites.removeAll()
        saveHistory()
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Transformation].self, from: data) {
            favorites = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([Transformation].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
} 