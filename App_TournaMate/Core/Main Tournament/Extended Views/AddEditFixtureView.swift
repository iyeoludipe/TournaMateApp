import SwiftUI

struct AddEditFixtureView: View {
    var teams: [String] // This should be passed down from the parent view
    @State var fixture: Fixture
    var onSave: (Fixture) -> Void

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $fixture.date, displayedComponents: .date)
                // Team A Picker
                Picker("Team A", selection: $fixture.teamA) {
                    ForEach(teams, id: \.self) { team in
                        Text(team).tag(team)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // This makes it a dropdown
                
                // Team B Picker
                Picker("Team B", selection: $fixture.teamB) {
                    ForEach(teams, id: \.self) { team in
                        Text(team).tag(team)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // This makes it a dropdown
                
                Button("Save") {
                    onSave(fixture)
                }
            }
            .navigationBarTitle("Edit Fixture")
        }
    }
}
