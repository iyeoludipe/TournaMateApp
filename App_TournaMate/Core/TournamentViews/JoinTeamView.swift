import SwiftUI
import Firebase
import FirebaseFirestore

struct JoinTeamView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var teamCode = ""
    @State private var errorMessage = ""
    @State private var isJoining = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject var viewModel: TournamentViewModel // Adjusted to use TournamentViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Join a Team")
                    .font(.title)
                    .padding()

                TextField("Enter Team Code", text: $teamCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button("Join Team") {
                    joinTeam()
                }
                .disabled(teamCode.isEmpty || isJoining)
                .padding()
                .background(teamCode.isEmpty || isJoining ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationBarTitle("Join Team", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Join Team"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK"), action: {
                        if errorMessage == "Successfully joined the team!" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }))
            }
        }
    }

    private func joinTeam() {
        isJoining = true
        viewModel.newJoinTeam(teamCode: teamCode) { success, message in
            self.isJoining = false
            self.alertMessage = message
            self.errorMessage = success ? "Successfully joined the team!" : message
            self.showAlert = true
        }
    }
}

// Ensure TournamentViewModel is initialized where it's needed and passed correctly.
