import SwiftUI

struct JoinTournamentView: View {
    @State private var tournamentCode: String = ""

    var body: some View {
        VStack {
            Text("Enter Tournament Code")
            TextField("Tournament Code", text: $tournamentCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Join Tournament") {
                // Implement the functionality to join a tournament by the code
                print("Join Tournament with code: \(tournamentCode)")
            }
            .padding()
        }
        .navigationBarTitle("Join Tournament", displayMode: .inline)
    }
}

struct JoinTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        JoinTournamentView()
    }
}
