import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Fixture: Codable, Comparable {
    var date: Date
    var teamA: String
    var teamB: String


    // Allows sorting of fixtures by date
    static func < (lhs: Fixture, rhs: Fixture) -> Bool {
        return lhs.date < rhs.date
    }
}


struct Tournament: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var uniqueID: String
    var fixtures: [Fixture]?  // Optional; not all tournaments may have fixtures set up initially
    var teamNames: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name = "tournament_name"  // Ensure this matches your Firestore field names
        case uniqueID = "unique_id"
        case fixtures
        case teamNames = "team_names"
    }

    // Finds the next fixture by date, relative to the current date
    func nextFixture() -> Fixture? {
        guard let fixtures = fixtures else { return nil }
        let upcomingFixtures = fixtures.filter { $0.date > Date() }
        return upcomingFixtures.sorted().first
    }
}
