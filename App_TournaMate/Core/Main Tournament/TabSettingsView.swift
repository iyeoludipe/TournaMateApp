import SwiftUI

struct TabSettingsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var tabViewModel: TabViewModel
    @StateObject var settingsViewModel: SettingsViewModel
    @State private var showingShareSheet = false
    
    var appVersion = "1.0.0"  // Ideally, fetched dynamically
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text(settingsViewModel.userInitials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(settingsViewModel.userFullName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(settingsViewModel.userEmail)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // General Section
                Section(header: Text("General")) {
                    SettingsRowView(imageName: "gear", title: "Version \(appVersion)", tintColor: Color(.systemGray))
                }
                
                // Tournaments Section
                Section(header: Text("Tournaments")) {
                    NavigationLink("Manage Fixtures", destination: ManageFixturesView().environmentObject(tabViewModel))
                    NavigationLink("Manage Teams", destination: ManageTeamsView().environmentObject(tabViewModel))
                    
                    Button("Invite To TournaMate") {
                        showingShareSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityView(activityItems: ["Join TournaMate: <URL to download app>"], applicationActivities: nil)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
            .onAppear {
                settingsViewModel.fetchCurrentUserDetails()
                
            }
        }
    }
}
