import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class TableViewModel: ObservableObject {
    @Published var teams: [Team] = []
    private var db = Firestore.firestore()
    private var selectedTournamentUniqueID: String?

    // Initialize TableViewModel with the selected tournament ID
    init(selectedTournamentID: String? = nil) {
        self.selectedTournamentUniqueID = selectedTournamentID
        if let tournamentID = selectedTournamentID {
            fetchTeamsForTournament(tournamentID: tournamentID)
        }
    }
    
    // Fetch the current tournament ID based on the selected tournament
    func fetchCurrentTournamentID(completion: @escaping (String?) -> Void) {
        if let tournamentID = selectedTournamentUniqueID {
            completion(tournamentID)
        } else {
            // Implement your logic here if there is no selectedTournamentUniqueID
            // For example, you could fetch the user's last viewed tournament ID from Firestore
            // This is a placeholder for demonstration purposes
            let usersRef = Firestore.firestore().collection("users")
            guard let userEmail = Auth.auth().currentUser?.email else {
                print("No user logged in")
                completion(nil)
                return
            }
            
            usersRef.document(userEmail).getDocument { document, error in
                if let document = document, let lastViewedTournamentID = document.data()?["lastViewedTournamentID"] as? String {
                    completion(lastViewedTournamentID)
                } else {
                    print("Could not fetch last viewed tournament ID for user: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }

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
