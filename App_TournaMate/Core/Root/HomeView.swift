import SwiftUI

struct HomeView: View {
    @State private var isAccountViewPresented = false
    @State private var showingCreateTournamentView = false

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
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarTitle("TournaMate", displayMode: .inline)
        // Ensure no sign out button is added
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
