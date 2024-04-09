import SwiftUI

struct MainTournamentView: View {
    var body: some View {
        TabView {
            TabHomeView()
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

struct MainTournamentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTournamentView()
    }
}
