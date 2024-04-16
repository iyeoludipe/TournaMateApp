import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class TournamentViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var selectedTournamentsUniqueID: String?
    private var db = Firestore.firestore()

    init() {
        // Initialization code can go here
    }
    
    func addFixture(toTournament tournamentID: String, teamA: String, teamB: String, date: Timestamp, completion: @escaping (Bool, String) -> Void) {
            let newFixture: [String: Any] = [
                "date": date,
                "teamA": teamA,
                "teamB": teamB
            ]
            
            let tournamentRef = db.collection("tournaments").document(tournamentID)
            
            tournamentRef.updateData([
                "fixtures": FieldValue.arrayUnion([newFixture])
            ]) { error in
                if let error = error {
                    completion(false, "Error adding fixture: \(error.localizedDescription)")
                } else {
                    completion(true, "Fixture added successfully")
                }
            }
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
            print("User not logged in or email unavailable")
            completion([])
            return
        }
        
        db.collection("users").document(userEmail).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let document = document, document.exists, let data = document.data(),
                  let tournamentCodes = data["tournaments"] as? [String], !tournamentCodes.isEmpty else {
                print("No tournaments found for user or error fetching document")
                completion([])
                return
            }
            
            var tournaments: [Tournament] = []
            let group = DispatchGroup()
            
            for code in tournamentCodes {
                group.enter()
                self.db.collection("tournaments").whereField("unique_id", isEqualTo: code).getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting tournament documents: \(err.localizedDescription)")
                    } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                        for document in querySnapshot.documents {
                            do {
                                let tournament = try document.data(as: Tournament.self)
                                tournaments.append(tournament)
                            } catch let decodeError {
                                print("Error decoding tournament: \(decodeError)")
                            }
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(tournaments)
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
                        if success {
                            // Updating the user's tournaments array
                            self.db.collection("users").document(userEmail).updateData([
                                "tournaments": FieldValue.arrayUnion([uniqueID])
                            ]) { error in
                                if let error = error {
                                    print("Error updating user's tournaments: \(error.localizedDescription)")
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                        } else {
                            completion(false)
                        }
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
    func newJoinTeam(teamCode: String, completion: @escaping (Bool, String) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(false, "User not logged in")
            return
        }

        let teamRef = db.collection("teams").document(teamCode)
        teamRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Team exists, proceed with adding user to team
                teamRef.updateData([
                    "members": FieldValue.arrayUnion([userEmail])
                ]) { error in
                    if let error = error {
                        completion(false, "Failed to join team: \(error.localizedDescription)")
                        return
                    }
                    // Add team code to user's 'teams_joined' array
                    self.db.collection("users").document(userEmail).updateData([
                        "teams_joined": FieldValue.arrayUnion([teamCode])
                    ]) { error in
                        if let error = error {
                            completion(false, "Failed to update user's teams: \(error.localizedDescription)")
                        } else {
                            completion(true, "Successfully joined the team!")
                        }
                    }
                }
            } else {
                completion(false, "No such team found. Please check the team code.")
            }
        }
    }

    
    func joinTeam(teamCode: String, userEmail: String, completion: @escaping (Bool, String) -> Void) {
            let teamRef = db.collection("teams").document(teamCode)

            // Check if team exists
            teamRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Team exists, proceed with adding user to team
                    teamRef.updateData([
                        "members": FieldValue.arrayUnion([userEmail])
                    ]) { error in
                        if let error = error {
                            completion(false, "Failed to join team: \(error.localizedDescription)")
                            return
                        }
                        // Add team code to user's 'teams_joined' array
                        self.db.collection("users").document(userEmail).updateData([
                            "teams_joined": FieldValue.arrayUnion([teamCode])
                        ]) { error in
                            if let error = error {
                                completion(false, "Failed to update user's teams: \(error.localizedDescription)")
                            } else {
                                completion(true, "Successfully joined the team!")
                            }
                        }
                    }
                } else {
                    completion(false, "No such team found. Please check the team code.")
                }
            }
        }
    }
