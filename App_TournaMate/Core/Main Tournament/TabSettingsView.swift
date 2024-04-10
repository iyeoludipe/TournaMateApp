import SwiftUI

struct TabSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabViewModel: TabViewModel
    let userFullName = "John Doe"
    let userEmail = "john@example.com"
    let appVersion = "1.0.0" // This should be fetched dynamically in your app

    var body: some View {
        List {
            Section {
                HStack {
                    Text("JD") // Placeholder for user initials
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 72, height: 72)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userFullName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(userEmail)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("General")) {
                SettingsRowView(imageName: "gear", title: "Version \(appVersion)", tintColor: Color(.systemGray))
            }
            
            Section(header: Text("Tournaments")) {
                Button(action: {
                    // Placeholder for row1 action
                    Text("Action")
                }) {
                    Text("Row1")
                }
                
                Button(action: {
                    // Placeholder for row2 action
                    Text("Action")
                }) {
                    Text("Row2")
                }
            
                
                Button(action: {
                    // Placeholder for row3 action
                    Text("Action")
                }) {
                    Text("Row3")
                }
                
            }
            
            Section(header: Text("Account")) {
                Button(action: {
                    print("Signed out")
                }) {
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                }
                
                Button(action: {
                    // Placeholder for delete account action
                    Text("Password Reset")
                }) {
                    SettingsRowView(imageName: "arrow.clockwise.circle.fill", title: "Reset Password", tintColor: .red)
                }
                
                Button(action: {
                    // Placeholder for delete account action
                    Text("Confirm you want to delete your account")
                }) {
                    SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Settings")
        }
    }


struct TabSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TabSettingsView().environmentObject(TabViewModel())
    }
}
