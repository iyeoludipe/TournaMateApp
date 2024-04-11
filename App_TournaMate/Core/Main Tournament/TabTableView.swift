import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TabTableView: View {
    @ObservedObject var viewModel = TabViewModel() // This is the correct line

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
            
            List(viewModel.teams) { team in
                HStack {
                    Text("\(team.name)")
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
            viewModel.fetchTeams()
        }
        .navigationBarTitle("League Table", displayMode: .inline)
    }
}

struct TabTableView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabTableView(viewModel: TabViewModel())
        }
    }
}
