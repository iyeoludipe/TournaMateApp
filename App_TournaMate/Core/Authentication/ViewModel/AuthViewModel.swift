import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

struct AuthError: Identifiable, Equatable {
    let message: String
    let id: UUID = UUID()

    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? = nil
    private var handle: AuthStateDidChangeListenerHandle?
    @Published var currentUser: UserModel?
    @Published var authError: AuthError?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.userSession = user
            if let user = user {
                Task {
                    await self?.fetchUser()
                }
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: UserModel.self)
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.authError = nil
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login with \(error.localizedDescription)")
            self.authError = AuthError(message: "Failed to sign in. Please check your email and password and try again.")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            // Create the user with email and password
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Prepare the user data for Firestore
            let userData: [String: Any] = [
                "email": email,
                "full_name": fullname,
                "is_admin": false,
                "teams_joined": [String](),
                "tournaments": [String]()
            ]
            
            // Set the user data in Firestore using the email as the document ID
            try await Firestore.firestore().collection("users").document(email).setData(userData)
            
            // Fetch the current user data to update the local state
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user \(error.localizedDescription)")
            throw error  // Rethrow the error to be handled by the caller if needed
        }
    }

    
    func sendPasswordReset(withEmail email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset: \(error.localizedDescription)")
                completion(false, "Failed to send password reset email. Please check your email and try again.")
            } else {
                completion(true, nil)
            }
        }
    }
    
    var signOutCompletion: (() -> Void)?
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            
            signOutCompletion?()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func deleteAccount(completion: @escaping(Bool, String) -> Void) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                //An error
                completion(false, error.localizedDescription)
            } else {
                // Account deleted
                self.userSession = nil
                completion(true, "Account successfully deleted")
            }
        }
    }
}
