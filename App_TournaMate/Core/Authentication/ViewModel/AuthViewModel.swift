import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

struct AuthError: Equatable {
    let message: String
    let id: UUID = UUID()

    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?
    @Published var authError: AuthError?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.authError = nil // Consider removing this if you reset `authError` elsewhere before calling signIn
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login with \(error.localizedDescription)")
            self.authError = AuthError(message: "Failed to sign in. Please check your email and password and try again.")

        }
    }

    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = UserModel(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user \(error.localizedDescription)")
            
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
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil
            self.currentUser = nil
            
            signOutCompletion?()
        } catch {
            print("DEBUG: Failed to sign out with \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: UserModel.self)
        
    }
}
