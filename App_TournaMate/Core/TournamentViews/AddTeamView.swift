import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AddTeamView: View {
    @Binding var teams: [Team]
    @Binding var isAddTeamViewPresented: Bool
    var onTeamCreated: ((String, String) -> Void)? // Adjusted for two parameters
    @Environment(\.presentationMode) var presentationMode
    @State private var teamName: String = ""

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
        let teamRef = db.collection("teams").document()
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No logged in user found")
            return
        }
        let teamData: [String: Any] = [
            "team_name": teamName,
            "members": [userEmail],
            "created_at": FieldValue.serverTimestamp()
        ]

        teamRef.setData(teamData) { error in
            if let error = error {
                print("Error adding team: \(error.localizedDescription)")
            } else {
                print("Team added with ID: \(teamRef.documentID)")
                DispatchQueue.main.async {
                    self.onTeamCreated?(teamRef.documentID, self.teamName) // Ensure to call it safely
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct AddTeamView_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamView(teams: .constant([]), isAddTeamViewPresented: .constant(true), onTeamCreated: { _, _ in })
    }
}
