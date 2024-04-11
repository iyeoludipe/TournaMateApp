import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MyTournamentsView: View {
    @ObservedObject var viewModel = TournamentViewModel()
    @State private var myTournaments: [Tournament] = []

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            VStack {
                List(myTournaments) { tournament in
                    NavigationLink(destination: MainTournamentView(tabViewModel: TabViewModel(selectedTournamentID: tournament.uniqueID), tableViewModel: TableViewModel())) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tournament.name)
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationBarTitle("My Tournaments", displayMode: .large)
        }
        .onAppear {
            viewModel.fetchMyTournaments { tournaments in
                self.myTournaments = tournaments
            }
        }
    }
}
