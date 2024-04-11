import FirebaseFirestoreSwift
import Firebase

struct Team: Identifiable, Codable {
    var id: String
    var name: String
    var players: Int
    var teamStats: TeamStats  // Assuming you have a nested structure for stats
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case players
        case teamStats = "team_stats"  // The key in your Firestore document
    }
    
    struct TeamStats: Codable {
        var wins: Int
        var draws: Int
        var losses: Int
        var points: Int
    }
}
