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
                if let fixtures = tournament.fixtures {
                    self.fixtures = fixtures.sorted { $0.date < $1.date }
                    self.fetchTeamsAndUpdateFixtures()  // Fetch teams and update fixture names
                } else {
                    self.fixtures = []
                }
                self.nextFixture = self.determineNextFixture()  // Update next fixture after fetching teams
            } catch {
                print("Error decoding tournament: \(error.localizedDescription)")
            }
        }
    }


    func fetchTeamsAndUpdateFixtures() {
        guard let tournamentID = selectedTournamentUniqueID, let fixtures = currentTournament?.fixtures else { return }
        
        db.collection("teams").whereField("tournament_id", isEqualTo: tournamentID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            var teamNameMap = [String: String]()
            self.teams = querySnapshot?.documents.compactMap { document -> Team? in
                let team = try? document.data(as: Team.self)
                if let team = team, let teamID = team.id {
                    teamNameMap[teamID] = team.name
                }
                return team
            } ?? []

            self.updateFixtureNames(with: teamNameMap)
        }
    }


    private func updateFixtureNames(with teamNameMap: [String: String]) {
        for (index, fixture) in fixtures.enumerated() {
            if let teamAName = teamNameMap[fixture.teamA], let teamBName = teamNameMap[fixture.teamB] {
                fixtures[index].teamA = teamAName
                fixtures[index].teamB = teamBName
            }
        }
        nextFixture = determineNextFixture()  // Recalculate next fixture with updated names
    }
        private func determineNextFixture() -> Fixture? {
            return fixtures.first(where: { $0.date > Date() })  // Find the next fixture based on date
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

    func getCurrentPosition(userEmail: String, completion: @escaping (String) -> Void) {
            guard let tournamentID = selectedTournamentUniqueID else {
                completion("N/A") // No tournament selected
                return
            }
            
            db.collection("teams")
              .whereField("members", arrayContains: userEmail)
              .whereField("tournament_id", isEqualTo: tournamentID)
              .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion("N/A")
                    return
                }

                // Find the player's team
                guard let playerTeam = querySnapshot?.documents.compactMap({ document -> Team? in
                    return try? document.data(as: Team.self)
                }).first else {
                    completion("N/A")
                    return
                }
                
                // Now fetch all teams in the tournament to calculate the position
                self.db.collection("teams")
                  .whereField("tournament_id", isEqualTo: tournamentID)
                  .getDocuments { (allTeamsSnapshot, allTeamsError) in
                    if let allTeamsError = allTeamsError {
                        print("Error getting all teams documents: \(allTeamsError)")
                        completion("N/A")
                        return
                    }

                    let teams = allTeamsSnapshot?.documents.compactMap({ document -> Team? in
                        return try? document.data(as: Team.self)
                    }) ?? []
                    
                    // Sort teams by points
                    let sortedTeams = teams.sorted(by: { $0.teamStats.points > $1.teamStats.points })

                    // Find the index (position) of the player's team in the sorted array
                    if let positionIndex = sortedTeams.firstIndex(where: { $0.id == playerTeam.id }) {
                        completion("\(self.ordinalNumber(positionIndex + 1))") // "+ 1" because array index starts from 0
                    } else {
                        completion("N/A")
                    }
                }
            }
        }
        
        // Helper function to convert number to its ordinal representation
        private func ordinalNumber(_ number: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
        }
    }

