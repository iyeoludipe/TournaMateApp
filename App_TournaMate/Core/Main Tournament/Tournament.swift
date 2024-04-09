import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Tournament: Identifiable, Codable {
    var id: String // Firestore document ID
    var name: String // Name of the tournament
    var uniqueID: String // The 5-digit unique identifier for the tournament
    // ... Add other tournament-related properties, such as dates, participants, etc.

    // Custom initializer to decode a Firestore document into a Tournament model
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["tournament_name"] as? String else {
            print("Error decoding document \(document.documentID): 'tournament_name' field is missing")
            return nil
        }
        
        guard let uniqueID = data["unique_id"] as? String else {
            print("Error decoding document \(document.documentID): 'unique_id' field is missing")
            return nil
        }

        self.id = document.documentID
        self.name = name
        self.uniqueID = uniqueID
    }



}
