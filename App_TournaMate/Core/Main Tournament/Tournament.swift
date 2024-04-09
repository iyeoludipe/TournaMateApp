import Foundation

struct Tournament: Identifiable, Codable {
    var id: String // Unique identifier for the tournament, such as the Firestore document ID
    var name: String // Name of the tournament
    var uniqueID: Int // The 5-digit unique identifier for the tournament
    // ... Add other tournament-related properties, such as dates, participants, etc.
}

