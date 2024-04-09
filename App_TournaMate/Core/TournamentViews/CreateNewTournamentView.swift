import SwiftUI
import FirebaseFirestore

struct CreateNewTournamentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = TournamentViewModel()
    @State private var tournamentCode = ""
    @State private var tournamentName = ""
    @State private var defaultLocation = ""
    @State private var tournamentMode: TournamentMode = .league
    @State private var pointsForWins = 3
    @State private var pointsForTies = 1
    @State private var pointsForLosses = 0
    @State private var teams = [Team]()
    @State private var teamName: String = ""
    @State private var isAddTeamViewPresented = false
    @State private var showingCreationAlert = false
    @State private var lastCreatedTeamId: String? = nil // This will now directly store the team ID when a team is successfully created

    enum TournamentMode: String, CaseIterable, Identifiable {
        case league = "League", knockout = "Knockout"
        var id: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tournament Code: \(tournamentCode)")
                    .padding(.horizontal)

                InputView(text: $tournamentName, title: "Tournament Name", placeholder: "Enter tournament name")
                
                Picker("Mode", selection: $tournamentMode) {
                    ForEach(TournamentMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                InputView(text: $defaultLocation, title: "Default Location", placeholder: "Enter default location")
                
                Stepper("Points for Wins: \(pointsForWins)", value: $pointsForWins, in: 1...10)
                Stepper("Points for Ties: \(pointsForTies)", value: $pointsForTies, in: 0...10)
                Stepper("Points for Losses: \(pointsForLosses)", value: $pointsForLosses, in: 0...10)

                Spacer()
                
                Button("Add Team") {
                    isAddTeamViewPresented = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
                
                Button("Create Tournament") {
                    guard let teamId = lastCreatedTeamId, !tournamentName.isEmpty, !defaultLocation.isEmpty else {
                        print("Missing information to create the tournament.")
                        return
                    }
                    // Use the team ID to create the tournament and associate the team with it
                    viewModel.createTournament(tournamentName: tournamentName, location: defaultLocation, teamName: self.teamName, teamID: teamId) { success in
                        if success {
                            showingCreationAlert = true
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 20)
                .alert(isPresented: $showingCreationAlert) {
                    Alert(
                        title: Text("Tournament Created!"),
                        message: Text("Go to 'My Tournaments' to view it."),
                        dismissButton: .default(Text("OK")) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    )
                }


                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isAddTeamViewPresented) {
            AddTeamView(teams: $teams, isAddTeamViewPresented: $isAddTeamViewPresented, onTeamCreated: { (teamId, teamNameReceived) in
                self.lastCreatedTeamId = teamId
                self.teamName = teamNameReceived // Make sure to have this State variable declared.
            })
        }

        .navigationTitle("Create New Tournament")
        .navigationBarItems(leading: Button("Dismiss") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            viewModel.fetchNextTournamentID { newID in
                if let newID = newID {
                    self.tournamentCode = newID
                } else {
                    print("Failed to fetch the next tournament ID")
                }
            }
        }
    }
}

struct CreateNewTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewTournamentView()
    }
}
