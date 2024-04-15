import SwiftUI

struct TabFixturesView: View {
    @ObservedObject var viewModel: TabViewModel // Assume this is passed from the parent view

    var body: some View {
        List {
            Section(header:
                Text("UPCOMING FIXTURES")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .textCase(nil) // Prevents the header from being uppercased automatically
            ) {
                ForEach(viewModel.fixtures) { fixture in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(fixture.teamA) vs \(fixture.teamB)")
                            .font(.headline)
                        Text("Date: \(fixture.formattedDate)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Divider().padding(.vertical, 2)
                }
            }
        }
        .listStyle(GroupedListStyle()) // Gives the list a grouped style which applies background to the section header
        .navigationBarTitle("Fixtures", displayMode: .large)
    }
}

extension Fixture: Identifiable {
    var id: String { UUID().uuidString }
    var matchDescription: String { "\(teamA) vs \(teamB)" }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
