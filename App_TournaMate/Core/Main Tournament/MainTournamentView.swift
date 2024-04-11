import SwiftUI

struct MainTournamentView: View {
    var tabViewModel: TabViewModel
    var tableViewModel: TableViewModel
    var settingsViewModel: SettingsViewModel
    
    init(tabViewModel: TabViewModel, tableViewModel: TableViewModel, settingsViewModel: SettingsViewModel) {
        self.tabViewModel = tabViewModel
        self.tableViewModel = tableViewModel
        self.settingsViewModel = settingsViewModel
    }
    var body: some View {
        TabView {
            TabHomeView(viewModel: tabViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            TabFixturesView(viewModel: tabViewModel)
                .tabItem {
                    Label("Fixtures", systemImage: "calendar")
                }
            
            TabTableView(viewModel: tableViewModel)
                .tabItem {
                    Label("Table", systemImage: "tablecells")
                }
            
            TabSettingsView(settingsViewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
