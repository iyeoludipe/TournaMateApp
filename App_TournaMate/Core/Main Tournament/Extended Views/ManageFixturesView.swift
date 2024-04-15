import SwiftUI

struct ManageFixturesView: View {
    @EnvironmentObject var tabViewModel: TabViewModel
    @State private var newTeamA = ""
    @State private var newTeamB = ""
    @State private var newDate = Date()
    @State private var selectedFixture: Fixture?
    @State private var editingDate = Date()
    @State private var editingTeamA = ""
    @State private var editingTeamB = ""

    var body: some View {
        List {
            Section(header: Text("Add Fixture")) {
                DatePicker("Date", selection: $newDate, displayedComponents: .date)
                TextField("Team A", text: $newTeamA)
                TextField("Team B", text: $newTeamB)
                Button("Add") {
                    addFixture()
                }
            }

            Section(header: Text("Edit Fixture")) {
                if let fixture = selectedFixture {
                    DatePicker("Date", selection: $editingDate, displayedComponents: .date)
                    TextField("Team A", text: $editingTeamA)
                    TextField("Team B", text: $editingTeamB)
                    Button("Update") {
                        updateFixture()
                    }
                }
            }

            Section(header: Text("Remove Fixture")) {
                // Implent functions
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Manage Fixtures", displayMode: .inline)
    }

    private func addFixture() {
        // Implement addition logic
        print("Add Fixture: \(newTeamA) vs \(newTeamB) on \(newDate)")
    }
    
    private func updateFixture() {
        // Implement update logic
        guard let fixture = selectedFixture else { return }
        print("Update Fixture: \(fixture.id ?? "") with \(editingTeamA) vs \(editingTeamB) on \(editingDate)")
    }

    private func removeFixture(at offsets: IndexSet) {
        // Implement deletion logic
        for index in offsets {
            let fixture = tabViewModel.fixtures[index]
            print("Remove Fixture: \(fixture.id ?? "")")
        }
    }
}
