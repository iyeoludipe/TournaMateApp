import FirebaseFirestoreSwift
import Firebase

struct Team: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var teamStats: TeamStats
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "team_name"  // The Firestore field for the team name seems to be 'team_name'
        case teamStats = "team_stats"
    }
    
    struct TeamStats: Codable {
        var wins: Int
        var draws: Int
        var losses: Int
        var points: Int
        
        enum CodingKeys: String, CodingKey {
            case wins
            case draws
            case losses
            case points = "pts"
        }
    }
}
