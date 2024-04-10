import SwiftUI

// Simplified and corrected TabHomeView
struct TabHomeView: View {
    @ObservedObject var viewModel: TabViewModel

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
                
                // Current Position (Placeholder as is, since no dynamic data fetching for position is set up yet)
                SectionView(title: "Current Position: 1st", iconName: "flag.fill")
                
                Divider().padding(.vertical, 2)
                
                // News (Placeholder as is)
                SectionView(title: "Latest News: The final match is scheduled for next week.", iconName: "newspaper.fill")
            }
            .padding() // Add padding around the VStack content
        }
        .navigationBarTitle("Home", displayMode: .inline) // Set the navigation bar title
        .onAppear {
            viewModel.getCurrentTournamentInfo()
        }
    }
}

// SectionView now only requires title and iconName, removed unnecessary viewModel
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

struct TabHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabHomeView(viewModel: TabViewModel()) // Ensure TabViewModel is initialized here for previews
        }
    }
}
