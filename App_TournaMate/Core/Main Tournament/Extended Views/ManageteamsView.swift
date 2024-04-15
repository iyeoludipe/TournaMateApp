import SwiftUI

struct ManageTeamsView: View {
    @EnvironmentObject var tabViewModel: TabViewModel
    @State private var newTeamName = ""
    @State private var selectedTeam: Team?
    @State private var editingTeamName = ""

    var body: some View {
        List {
            Section(header: Text("Add Team")) {
                TextField("Team Name", text: $newTeamName)
                Button("Add") {
                    addTeam()
                }
            }

            Section(header: Text("Edit Team")) {
                if let team = selectedTeam {
                    TextField("Team Name", text: $editingTeamName)
                    Button("Update") {
                        updateTeam()
                    }
                }
            }

            Section(header: Text("Remove Team")) {
                ForEach(tabViewModel.teams) { team in
                    Text(team.name)
                        .onTapGesture {
                            selectedTeam = team
                            editingTeamName = team.name
                        }
                }
                .onDelete(perform: removeTeam)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Manage Teams", displayMode: .inline)
    }

    private func addTeam() {
        // Implement addition logic
        print("Add Team: \(newTeamName)")
    }
    
    private func updateTeam() {
        // Implement update logic
        guard let team = selectedTeam else { return }
        print("Update Team: \(team.id ?? "") with \(editingTeamName)")
    }

    private func removeTeam(at offsets: IndexSet) {
        // Implement deletion logic
        for index in offsets {
            let team = tabViewModel.teams[index]
            print("Remove Team: \(team.id ?? "")")
        }
    }
}
