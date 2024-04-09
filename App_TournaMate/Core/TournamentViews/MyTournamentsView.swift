import SwiftUI

struct MyTournamentsView: View {
    @ObservedObject var viewModel = TournamentViewModel()
    @State private var myTournaments: [Tournament] = []

    var body: some View {
        List(myTournaments, id: \.id) { tournament in
            Text(tournament.name) // Assuming Tournament has a 'name' property
        }
        .navigationBarTitle("My Tournaments", displayMode: .inline)
        .onAppear {
            viewModel.fetchMyTournaments { tournaments in
                self.myTournaments = tournaments
            }
        }
    }
}

struct MyTournamentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyTournamentsView()
    }
}
