import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class TableViewModel: ObservableObject {
    @Published var teams: [Team] = []
    private var db = Firestore.firestore()

    func fetchTeamsForTournament(tournamentID: String) {
        db.collection("tournaments").document(tournamentID).getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Error fetching tournament document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let teamIDs = documentSnapshot.get("team_names") as? [String] else {
                print("Error getting team_names from tournament document")
                return
            }
            
            // Reset the teams array to ensure it's clear before adding new data
            self.teams = []
            
            for teamID in teamIDs {
                self.db.collection("teams").document(teamID).getDocument { teamDocumentSnapshot, teamError in
                    guard let teamDocumentSnapshot = teamDocumentSnapshot, teamDocumentSnapshot.exists else {
                        print("Error fetching team document for ID \(teamID): \(teamError?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    guard let team = try? teamDocumentSnapshot.data(as: Team.self) else {
                        print("Error decoding team data for document ID \(teamID)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.teams.append(team)
                    }
                }
            }
        }
    }
}
