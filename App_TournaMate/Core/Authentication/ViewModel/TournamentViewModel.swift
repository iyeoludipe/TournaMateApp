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

    func fetchNextTournamentID(completion: @escaping (String?) -> Void) {
        let tournamentIDRef = db.collection("counters").document("tournament_id")
        tournamentIDRef.getDocument { (document, error) in
            if let document = document, document.exists,
               let currentIDString = document.data()?["current_id"] as? String {
                let newIDString = String(format: "%05d", (Int(currentIDString) ?? 0) + 1)
                tournamentIDRef.updateData(["current_id": newIDString]) { err in
                    completion(err == nil ? newIDString : nil)
                }
            } else {
                print("Document does not exist or Error fetching document: \(String(describing: error))")
                completion(nil)
            }
        }
    }

    func updateAllRecords(tournamentCode: String, teamID: String, completion: @escaping (Bool) -> Void) {
        let teamRef = db.collection("teams").document(teamID)
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
    
    func fetchMyTournaments(completion: @escaping ([Tournament]) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion([])
            return
        }
        
        db.collection("users").document(userEmail).getDocument { (document, error) in
            if let document = document, let data = document.data(), let tournamentCodes = data["tournaments"] as? [String] {
                // Assuming each code is a unique_id in the tournaments collection
                var tournaments: [Tournament] = []
                let group = DispatchGroup()
                
                for code in tournamentCodes {
                    group.enter()
                    self.db.collection("tournaments").whereField("unique_id", isEqualTo: code).getDocuments { (querySnapshot, err) in
                        // Inside the loop that fetches each tournament document
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                            for document in querySnapshot.documents {
                                if let tournament = Tournament(document: document) {
                                    tournaments.append(tournament)
                                }
                            }
                        }
                        group.leave()

                    }
                }
                
                group.notify(queue: .main) {
                    completion(tournaments)
                }
            } else {
                print("Document does not exist or Error fetching document: \(String(describing: error))")
                completion([])
            }
        }
    }


    func createTournament(tournamentName: String, location: String, teamName: String, teamID: String, completion: @escaping (Bool) -> Void) {
        fetchNextTournamentID { [weak self] uniqueID in
            guard let self = self, let uniqueID = uniqueID else {
                completion(false)
                return
            }
            
            let userEmail = Auth.auth().currentUser?.email ?? "unknown"
            let tournamentData: [String: Any] = [
                "tournament_name": tournamentName,
                "unique_id": uniqueID,
                "created_at": FieldValue.serverTimestamp(),
                "metadata": ["location": location],
                "team_names": [teamName],
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
    
    func joinTournament(tournamentCode: String, completion: @escaping (Bool, String) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(false, "User not logged in")
            return
        }
        
        let tournamentsRef = db.collection("tournaments").whereField("unique_id", isEqualTo: tournamentCode)
        tournamentsRef.getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, !documents.isEmpty,
                  let document = documents.first else {
                completion(false, "Tournament not found")
                return
            }
            
            let tournamentID = document.documentID
            
            // Add the user's email to the tournament's participants array
            self?.db.collection("tournaments").document(tournamentID).updateData([
                "participants": FieldValue.arrayUnion([userEmail])
            ]) { error in
                if let error = error {
                    completion(false, "Failed to join tournament: \(error.localizedDescription)")
                    return
                }
                
                // Add the tournament code to the user's tournaments field
                self?.db.collection("users").document(userEmail).updateData([
                    "tournaments": FieldValue.arrayUnion([tournamentCode])
                ]) { error in
                    if let error = error {
                        completion(false, "Failed to update user record: \(error.localizedDescription)")
                    } else {
                        completion(true, "Successfully joined the tournament")
                    }
                }
            }
        }
    }
}
