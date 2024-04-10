import SwiftUI
import Firebase
import FirebaseCore

@main
struct App_TournaMateApp: App {
    @StateObject var authViewModel = AuthViewModel() // Use AuthViewModel
    @StateObject var rootViewModel = RootViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authViewModel.userSession != nil {
                    HomeView(rootViewModel: rootViewModel) // User is logged in, show HomeView
                        .environmentObject(authViewModel)
                } else {
                    LoginView() // No user is logged in, show LoginView
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}

