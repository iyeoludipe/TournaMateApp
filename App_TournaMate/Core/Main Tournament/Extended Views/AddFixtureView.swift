import SwiftUI
import Firebase

struct AddFixtureView: View {
    @ObservedObject var viewModel: TournamentViewModel
    @State private var teamA: String = ""
    @State private var teamB: String = ""
    @State private var date: Date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var tournamentID: String  // Assuming you pass this to the view

    var body: some View {
        Form {
            Picker("Select Team A", selection: $teamA) {
                // Replace this with your actual teams fetched from Firestore
                ForEach(["Team 1", "Team 2", "Team 3"], id: \.self) { team in
                    Text(team).tag(team)
                }
            }
            
            Picker("Select Team B", selection: $teamB) {
                // Replace this with your actual teams fetched from Firestore
                ForEach(["Team 1", "Team 2", "Team 3"], id: \.self) { team in
                    Text(team).tag(team)
                }
            }
            
            DatePicker("Select Date", selection: $date, displayedComponents: .date)
            
            Button("Add Fixture") {
                let timestamp = Timestamp(date: date)
                viewModel.addFixture(toTournament: tournamentID, teamA: teamA, teamB: teamB, date: timestamp) { success, message in
                    self.alertMessage = message
                    self.showingAlert = true
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Fixture Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
