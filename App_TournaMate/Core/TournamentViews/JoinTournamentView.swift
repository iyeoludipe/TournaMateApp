import SwiftUI

struct JoinTournamentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var tournamentCode: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var joinSuccess = false // Track the success state
    @ObservedObject var viewModel = TournamentViewModel()

    var body: some View {
        VStack {
            Text("Enter Tournament Code")
            TextField("Tournament Code", text: $tournamentCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Join Tournament") {
                viewModel.joinTournament(tournamentCode: tournamentCode) { success, message in
                    self.joinSuccess = success // Update the success state based on the operation result
                    self.alertMessage = message
                    self.showAlert = true
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text(joinSuccess ? "Success" : "Error"), // Use joinSuccess here
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")) {
                          if joinSuccess {
                              self.presentationMode.wrappedValue.dismiss()
                          }
                      })
            }
        }
        .navigationBarTitle("Join Tournament", displayMode: .inline)
    }
}

struct JoinTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        JoinTournamentView()
    }
}
