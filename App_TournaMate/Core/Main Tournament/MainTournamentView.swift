import SwiftUI

struct MainTournamentView: View {
    var tabViewModel: TabViewModel
    var tableViewModel: TableViewModel
    
    init(tabViewModel: TabViewModel, tableViewModel: TableViewModel) {
        self.tabViewModel = tabViewModel
        self.tableViewModel = tableViewModel
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
            
            TabSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
