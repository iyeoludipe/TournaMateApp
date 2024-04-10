import SwiftUI

struct MainTournamentView: View {
    let tabViewModel: TabViewModel
    var body: some View {
        TabView {
            TabHomeView(viewModel: tabViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            TabFixturesView()
                .tabItem {
                    Label("Fixtures", systemImage: "calendar")
                }
            
            TabTableView()
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
