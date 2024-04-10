import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class TabViewModel: ObservableObject {
    @Published var isAdmin = false

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
