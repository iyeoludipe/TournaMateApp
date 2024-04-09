import SwiftUI
import Firebase

struct AddTeamView: View {
    @Binding var teams: [Team]
    @Binding var isAddTeamViewPresented: Bool
    var onTeamCreated: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var teamName = ""
    @State private var players = 1 // Assuming the creator is the first player
    
    private let currentUserEmail = Auth.auth().currentUser?.email ?? "unknown@unknown.com"

    var body: some View {
        NavigationView {
            VStack {
                Text("Add Team")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()

                TextField("Team Name", text: $teamName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()

                Button(action: {
                    addTeam()
                }) {
                    Text("Add Team")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func addTeam() {
        let db = Firestore.firestore()
        let teamRef = db.collection("teams").document() // Corrected to properly initialize teamRef
        // Preparing the team data with the creator as the first member
        let teamData: [String: Any] = [
            "team_name": teamName,
            "members": [currentUserEmail],
            "created_at": FieldValue.serverTimestamp()
        ]

        // Creating the team document in the Firestore database
        teamRef.setData(teamData) { error in
            if let error = error {
                print("Error adding team: \(error)")
            } else {
                print("Team added with ID: \(teamRef.documentID)")
                DispatchQueue.main.async {
                    self.onTeamCreated(teamRef.documentID) // Callback to notify the team creation with its ID
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage
        AddTeamView(teams: .constant([]), isAddTeamViewPresented: .constant(true), onTeamCreated: { _ in })
    }
}
