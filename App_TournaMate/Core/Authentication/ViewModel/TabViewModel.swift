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
            db.collection("teams").getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let querySnapshot = querySnapshot {
                    self.teams = querySnapshot.documents.compactMap { document -> Team? in
                        let result = Result { try document.data(as: Team.self) }
                        switch result {
                        case .success(let team):
                            return team
                        case .failure(let error):
                            print("Error decoding team: \(error)")
                            return nil
                        }
                    }.sorted { $0.teamStats.points > $1.teamStats.points }
                } else if let error = error {
                    print("Error getting documents: \(error)")
                }
            }
        }
    }

