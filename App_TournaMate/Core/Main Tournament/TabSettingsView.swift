import SwiftUI

struct TabSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabViewModel: TabViewModel
    @StateObject var settingsViewModel: SettingsViewModel
    
    var appVersion = "1.0.0" // Ideally, fetched dynamically
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text(settingsViewModel.userInitials) // Use initials from settingsViewModel
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(settingsViewModel.userFullName) // Full name from settingsViewModel
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(settingsViewModel.userEmail) // Email from settingsViewModel
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
                    NavigationLink("Manage Fixtures", destination: ManageFixturesView())
                    NavigationLink("Manage Teams", destination: ManageteamsView())
                    
                    Button("Invite To TournaMate") {
                        // Action for Row3
                    }
                }
                
                // Account Section
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        // Sign out action
                    }
                    .foregroundColor(.red)
                    
                    Button("Reset Password") {
                        // Reset Password action
                    }
                    .foregroundColor(.red)
                    
                    Button("Delete Account") {
                        // Delete Account action
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
            .onAppear {
                settingsViewModel.fetchCurrentUserDetails() // Fetch user details when view appears
            }
        }
    }
}
