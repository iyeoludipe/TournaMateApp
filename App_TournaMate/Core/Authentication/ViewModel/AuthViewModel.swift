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
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            
            signOutCompletion?()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func deleteAccount() {
        // Implement account deletion logic here
    }
}
