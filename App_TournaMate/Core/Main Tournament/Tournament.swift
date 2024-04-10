import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Define a struct for a fixture.
struct Fixture: Codable, Comparable {
    var date: Date
    var teamA: String
    var teamB: String

    // Implementing Comparable to easily sort fixtures by date
    static func < (lhs: Fixture, rhs: Fixture) -> Bool {
        return lhs.date < rhs.date
    }
}

// Define the main Tournament struct.
struct Tournament: Identifiable, Codable {
    @DocumentID var id: String? // Use @DocumentID for automatic Firestore ID handling
    var name: String
    var uniqueID: String
    var fixtures: [Fixture]? // Optional, since a tournament might not have fixtures yet

    // Firestore field names might differ from your struct's property names.
    // If they match exactly, you don't need to customize this.
    enum CodingKeys: String, CodingKey {
        case id
        case name = "tournament_name" // Adjust if your Firestore uses different field names
        case uniqueID = "unique_id"
        case fixtures
    }

    // Finds the next fixture based on the current date.
    func nextFixture() -> Fixture? {
        guard let fixtures = fixtures else { return nil }
        let upcomingFixtures = fixtures.filter { $0.date > Date() }
        return upcomingFixtures.sorted().first
    }
}
