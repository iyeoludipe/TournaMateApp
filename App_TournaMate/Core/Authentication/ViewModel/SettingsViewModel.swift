import Foundation
import Firebase
import FirebaseFirestore

class SettingsViewModel: ObservableObject {
    @Published var userFullName: String = ""
    @Published var userEmail: String = ""
    @Published var userInitials: String = ""
    @Published var teamCode: String = ""

    private var db = Firestore.firestore()

    func fetchTeamCode(teamID: String) {
            let db = Firestore.firestore()
            let teamRef = db.collection("teams").document(teamID)
            teamRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.teamCode = document.data()?["team_id"] as? String ?? "No Code"
                } else {
                    print("Document does not exist")
                }
            }
        }
    
    func fetchCurrentUserDetails() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No user logged in")
            return
        }

        db.collection("users").document(userEmail).getDocument { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, document.exists else {
                print("User document fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let userData = document.data()
            self.userFullName = userData?["full_name"] as? String ?? ""
            self.userEmail = userData?["email"] as? String ?? userEmail // Use the email from Auth as a fallback

            // Calculate initials
            self.userInitials = self.calculateInitials(from: self.userFullName)
        }
    }
    
    private func calculateInitials(from fullName: String) -> String {
        let names = fullName.components(separatedBy: " ")
        let initials = names.compactMap { $0.first }.map { String($0) }
        return initials.joined()
    }
}
