import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class TournamentViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    private var db = Firestore.firestore()

    init() {
        // Initialization code can go here
    }

    // This function fetches the next tournament ID, increments it, and updates Firestore.
    func fetchNextTournamentID(completion: @escaping (String?) -> Void) {
        let tournamentIDRef = db.collection("counters").document("tournament_id")

        tournamentIDRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let currentIDString = document.data()?["current_id"] as? String {
                    let newIDString = String(format: "%05d", (Int(currentIDString) ?? 0) + 1)
                    tournamentIDRef.updateData(["current_id": newIDString]) { err in
                        completion(err == nil ? newIDString : nil)
                    }
                } else {
                    completion(nil)
                }
            } else {
                print("Document does not exist or Error fetching document: \(String(describing: error))")
                completion(nil)
            }
        }
    }
    
    func updateAllRecords(tournamentCode: String, teamID: String, completion: @escaping (Bool) -> Void) {
        let teamRef = self.db.collection("teams").document(teamID)
        teamRef.updateData([
            "tournament_id": tournamentCode
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating team with tournament_id: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Team successfully updated with tournament_id")
                    completion(true)
                }
            }
        }
    }


    // This function creates a new tournament with the provided details and updates the "counters" document.
    func createTournament(tournamentName: String, location: String, teamName: String, teamID: String, completion: @escaping (Bool) -> Void) {
        fetchNextTournamentID { [weak self] uniqueID in
            guard let self = self, let uniqueID = uniqueID else {
                completion(false)
                return
            }
            
            // Fetch the current user's email
            let userEmail = Auth.auth().currentUser?.email ?? "unknown"
            
            let tournamentData: [String: Any] = [
                "tournament_name": tournamentName,
                "unique_id": uniqueID,
                "created_at": FieldValue.serverTimestamp(),
                "metadata": ["location": location],
                "team_names": [teamName], // Assuming this to be an array
                "participants": [userEmail]
            ]
            
            self.db.collection("tournaments").document(uniqueID).setData(tournamentData) { error in
                if let error = error {
                    print("Error creating tournament: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.updateAllRecords(tournamentCode: uniqueID, teamID: teamID) { success in
                        completion(success)
                    }
                }
            }
        }
    }

}
