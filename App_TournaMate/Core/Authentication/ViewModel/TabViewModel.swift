import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class TabViewModel: ObservableObject {
    @Published var isAdmin = false
    @Published var selectedTournamentUniqueID: String?
    @Published var currentTournament: Tournament?
    @Published var nextFixture: Fixture?
    private var db = Firestore.firestore()
    
    init(selectedTournamentID: String? = nil) {
        self.selectedTournamentUniqueID = selectedTournamentID
        if selectedTournamentID != nil {
            getCurrentTournamentInfo()
        }
    }

        
    func userDidSelectTournament(tournamentID: String) {
            self.selectedTournamentUniqueID = tournamentID
            getCurrentTournamentInfo()
        }
    

    func getCurrentTournamentInfo() {
        guard let tournamentID = selectedTournamentUniqueID else {
            print("No tournament ID selected")
            return
        }
        
        db.collection("tournaments").document(tournamentID).getDocument { [weak self] documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists, let self = self else {
                print("Error fetching tournament: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let tournament = try documentSnapshot.data(as: Tournament.self)
                self.currentTournament = tournament
                self.nextFixture = tournament.nextFixture() // Calculate and set the next fixture
            } catch {
                print("Error decoding tournament: \(error.localizedDescription)")
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
    }
}
