import SwiftUI
import Firebase
import FirebaseCore

@main
struct App_TournaMateApp: App {
    @StateObject var authViewModel = AuthViewModel() // Correct instantiation
    @StateObject var tabViewModel = TabViewModel()   // Make sure it's instantiated like this

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authViewModel.userSession != nil {
                    HomeView()
                        .environmentObject(authViewModel)
                        .environmentObject(tabViewModel) // Pass the instance, not the type
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
