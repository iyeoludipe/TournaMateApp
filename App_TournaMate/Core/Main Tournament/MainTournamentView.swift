import SwiftUI

struct MainTournamentView: View {
    @StateObject var tabViewModel = TabViewModel()
    @StateObject var tableViewModel = TableViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            TabHomeView(viewModel: tabViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .environmentObject(tabViewModel) // Inject TabViewModel into the environment

            TabFixturesView(viewModel: tabViewModel)
                .tabItem {
                    Label("Fixtures", systemImage: "calendar")
                }
                .environmentObject(tabViewModel) // This may not be necessary if TabFixturesView directly accepts the viewModel as a parameter

            TabTableView(viewModel: tableViewModel)
                .tabItem {
                    Label("Table", systemImage: "tablecells")
                }
                .environmentObject(tableViewModel)

            TabSettingsView(settingsViewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .environmentObject(settingsViewModel)
                .environmentObject(tabViewModel) // Ensure TabViewModel is also available in settings
        }
    }
}
