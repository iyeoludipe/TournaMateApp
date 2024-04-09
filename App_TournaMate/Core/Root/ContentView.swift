import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var shouldShowLoginView = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.userSession != nil {
                    HomeView()
                        .navigationBarBackButtonHidden(true) // Hide back button
                } else {
                    LoginView()
                        .background(
                            NavigationLink(
                                destination: EmptyView(),
                                isActive: $shouldShowLoginView,
                                label: { EmptyView() }
                            )
                        )
                }
            }
            .navigationTitle("TournaMate")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
