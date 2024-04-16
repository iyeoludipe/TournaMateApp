import SwiftUI

struct HomeView: View {
    @State private var isAccountViewPresented = false
    @ObservedObject var tournamentViewModel = TournamentViewModel()

    var body: some View {
        VStack {
            Image("TournaMateLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)

            Spacer()

            VStack(spacing: 20) {
                NavigationLink(destination: MyTournamentsView()) {
                    HomeButtonView(title: "MY TOURNAMENTS", color: .blue)
                }

                NavigationLink(destination: JoinTournamentView()) {
                    HomeButtonView(title: "JOIN TOURNAMENTS", color: .red)
                }

                NavigationLink(destination: CreateNewTournamentView()) {
                    HomeButtonView(title: "CREATE NEW TOURNAMENT", color: .green)
                }

                // Change this button to a NavigationLink
                NavigationLink(destination: JoinTeamView(viewModel: TournamentViewModel())) {
                    Text("New Player? Join Your Team")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarTitle("TournaMate", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isAccountViewPresented.toggle()
        }) {
            Image(systemName: "person.circle")
                .font(.title)
                .foregroundColor(.blue)
        })
        .sheet(isPresented: $isAccountViewPresented) {
            AccountView()
        }
    }
}

struct HomeButtonView: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.title2)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
