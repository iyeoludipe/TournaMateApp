import SwiftUI

struct MyTournamentsView: View {
    @ObservedObject var viewModel = TournamentViewModel()
    @State private var myTournaments: [Tournament] = []

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1) // Light gray background for the whole view
                .edgesIgnoringSafeArea(.all)

            VStack {
                List(myTournaments) { tournament in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tournament.name)
                                .font(.headline)
                            // Add more tournament details here if needed
                        }
                        Spacer()
                        NavigationLink(destination: MainTournamentView()) { // NavigationLink to MainTournamentView
                            Text("View")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white) // White background for each list item
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // Softer shadow
                }
                .listStyle(PlainListStyle()) // Removes extra padding and separators
            }
            .padding() // Padding around the list for spacing from screen edges
            .navigationBarTitle("My Tournaments", displayMode: .large) // Add navigation bar title
        }
        .onAppear {
            viewModel.fetchMyTournaments { tournaments in
                self.myTournaments = tournaments
            }
        }
    }
}

// Preview without NavigationView wrapper since it's already expected to be within one
struct MyTournamentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyTournamentsView()
    }
}
