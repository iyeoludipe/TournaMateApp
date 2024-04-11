import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TabTableView: View {
    @ObservedObject var viewModel: TableViewModel // This is correctly passed from the parent view

    var body: some View {
        VStack {
            Text("League Standings")
                .font(.title)
                .padding()

            HStack {
                Text("Pos")
                    .frame(width: 30, alignment: .leading)
                Spacer()
                Text("Team")
                    .frame(width: 140, alignment: .leading)
                Spacer()
                Text("W")
                    .frame(width: 30, alignment: .leading)
                Spacer()
                Text("D")
                    .frame(width: 30, alignment: .leading)
                Spacer()
                Text("L")
                    .frame(width: 30, alignment: .leading)
                Spacer()
                Text("Pts")
                    .frame(width: 50, alignment: .leading)
            }
            .font(.headline)
            .padding(.horizontal)

            // Dynamically display teams with their statistics
            List(viewModel.teams.indices, id: \.self) { index in
                let team = viewModel.teams[index]
                HStack {
                    Text("\(index + 1)") // Position based on the list index
                        .frame(width: 30, alignment: .leading)
                    Text(team.name)
                        .frame(width: 140, alignment: .leading)
                    Spacer()
                    Text("\(team.teamStats.wins)")
                        .frame(width: 30, alignment: .leading)
                    Spacer()
                    Text("\(team.teamStats.draws)")
                        .frame(width: 30, alignment: .leading)
                    Spacer()
                    Text("\(team.teamStats.losses)")
                        .frame(width: 30, alignment: .leading)
                    Spacer()
                    Text("\(team.teamStats.points)")
                        .frame(width: 50, alignment: .leading)
                }
                .padding(.vertical, 5)
            }
        }
        .onAppear {
            // This should ideally be triggered with the actual selected tournamentID
            // For now, using a hardcoded value for demonstration
            viewModel.fetchTeamsForTournament(tournamentID: "00001")
        }
        .navigationBarTitle("League Table", displayMode: .inline)
    }
}
