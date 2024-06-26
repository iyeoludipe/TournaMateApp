import SwiftUI
import Firebase
import FirebaseAuth

// Simplified and corrected TabHomeView
struct TabHomeView: View {
    @ObservedObject var viewModel: TabViewModel
    @State private var currentPosition: String = "Calculating..." // Added state variable for current position

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Tournament Information Header
                Text(viewModel.currentTournament?.name ?? "Tournament Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                Divider().padding(.vertical, 2)
                
                // Next Fixture
                if let nextFixture = viewModel.nextFixture {
                    SectionView(title: "Next Fixture: \(nextFixture.teamA) vs \(nextFixture.teamB)", iconName: "calendar")
                } else {
                    SectionView(title: "Next Fixture: Not Available", iconName: "calendar")
                }
                
                Divider().padding(.vertical, 2)
                
                // Current Position
                SectionView(title: "Current Position: \(currentPosition)", iconName: "flag.fill") // Now using currentPosition
                
                Divider().padding(.vertical, 2)
                
                // News (Placeholder as is)
                SectionView(title: "Latest News: The final match is scheduled for next week.", iconName: "newspaper.fill")
            }
            .padding() // Add padding around the VStack content
        }
        .navigationBarTitle("Home", displayMode: .inline) // Set the navigation bar title
        .onAppear {
            // Fetch tournament information
            if let tournamentID = viewModel.selectedTournamentUniqueID {
                viewModel.getCurrentTournamentInfo(tournamentID: tournamentID)
            } else {
                print("Tournament ID not set")
            }
            
            // Fetch current position
            if let userEmail = Auth.auth().currentUser?.email {
                viewModel.getCurrentPosition(userEmail: userEmail) { position in
                    self.currentPosition = position // Update the current position when fetched
                }
            }
        }
    }
}

// SectionView remains unchanged
struct SectionView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.blue) // Adjust icon color to fit your theme
            Text(title)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
