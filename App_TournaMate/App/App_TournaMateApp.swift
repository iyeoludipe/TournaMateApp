import SwiftUI
import Firebase
import FirebaseCore

@main
struct App_TournaMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var rootViewModel = RootViewModel()

    var body: some Scene {
            WindowGroup {
                NavigationView {
                    if rootViewModel.showTabHomeView {
                        TabHomeView()
                    } else {
                        HomeView(rootViewModel: RootViewModel())
                            .environmentObject(rootViewModel)
                    }
                }
        }
    }
}
