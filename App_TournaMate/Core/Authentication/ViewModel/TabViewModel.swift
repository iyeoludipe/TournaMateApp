import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class TabViewModel: ObservableObject {
    @Published var isAdmin = false
    @Published var selectedTournamentUniqueID: String?
    @Published var currentTournament: Tournament?
    @Published var nextFixture: Fixture?
    @Published var fixtures: [Fixture] = [] // Added to store fixtures
    @Published var teams: [Team] = []
    
    
    private var db = Firestore.firestore()
    
    init(selectedTournamentID: String? = nil) {
        self.selectedTournamentUniqueID = selectedTournamentID
        if let selectedTournamentID = selectedTournamentID {
            getCurrentTournamentInfo(tournamentID: selectedTournamentID)
        }
    }
    
    func userDidSelectTournament(tournamentID: String) {
        self.selectedTournamentUniqueID = tournamentID
        getCurrentTournamentInfo(tournamentID: tournamentID)
    }
    
    func getCurrentTournamentInfo(tournamentID: String) {
        db.collection("tournaments").document(tournamentID).getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Error fetching tournament: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let tournament = try documentSnapshot.data(as: Tournament.self)
                self.currentTournament = tournament
                // Once we have the tournament, fetch its fixtures if they exist.
                if let fixtures = tournament.fixtures {
                    self.fixtures = fixtures.sorted(by: { $0.date < $1.date })
                } else {
                    self.fixtures = []
                }
                self.nextFixture = tournament.nextFixture() // Calculate and set the next fixture
            } catch {
                print("Error decoding tournament: \(error.localizedDescription)")
            }
        }
    }
    
    
    // Call this function to check if the logged-in user is an admin
    func checkIfUserIsAdmin() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No user logged in")
            return
        }
        
        let usersRef = Firestore.firestore().collection("users")
        usersRef.document(userEmail).getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let userData = document.data(), let isAdmin = userData["is_admin"] as? Bool {
                    DispatchQueue.main.async {
                        self.isAdmin = isAdmin
                    }
                }
            }
        }
    }
    func fetchTeams() {
        guard let tournamentID = selectedTournamentUniqueID else {
            print("No tournament ID selected")
            return
        }
        
        db.collection("teams").whereField("tournament_id", isEqualTo: tournamentID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let querySnapshot = querySnapshot {
                print("Found \(querySnapshot.documents.count) teams for tournament ID \(tournamentID)")
                self.teams = querySnapshot.documents.compactMap { document -> Team? in
                    return try? document.data(as: Team.self)
                }.sorted { $0.teamStats.points > $1.teamStats.points }
            }
        }
        
    }
    func fetchSingleTeamForTest() {
        let hardcodedTeamID = "qf7bFzcnXZ9gMrynvFbA" // Replace with an actual ID from your Firestore
        
        db.collection("teams").document(hardcodedTeamID).getDocument { [weak self] documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                  let team = try? documentSnapshot.data(as: Team.self) else {
                print("Error fetching team: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.teams = [team] // Set your teams array to just this one team for the test
            }
        }
    }

    func fetchTeamsForSelectedTournament() {
        guard let tournamentID = selectedTournamentUniqueID else {
            print("No tournament ID selected")
            teams = [] // Ensure UI is clear if no tournament is selected
            return
        }
        
        // Fetch the selected tournament document to get the teamNames (team IDs)
        db.collection("tournaments").document(tournamentID).getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                  let tournament = try? documentSnapshot.data(as: Tournament.self),
                  let teamIDs = tournament.teamNames else {
                print("Error fetching tournament or tournament does not have team names: \(error?.localizedDescription ?? "Unknown error")")
                self?.teams = [] // Clear the teams if there's an issue fetching
                return
            }
            
            // Fetch team details for each ID and append to teams array
            for teamID in teamIDs {
                self.db.collection("teams").document(teamID).getDocument { (teamDocumentSnapshot, teamError) in
                    guard let teamDocumentSnapshot = teamDocumentSnapshot, teamDocumentSnapshot.exists,
                          let team = try? teamDocumentSnapshot.data(as: Team.self) else {
                        print("Error fetching team or team does not exist: \(teamError?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.teams.append(team)
                        // Optionally, sort teams array here if needed
                    }
                }
            }
        }
    }

}
