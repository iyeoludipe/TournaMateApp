import SwiftUI

struct FixtureRowView: View {
    let fixture: Fixture
    
    var body: some View {
        HStack {
            Text(fixture.teamA)
            Spacer()
            Text("vs")
            Spacer()
            Text(fixture.teamB)
        }
    }
}
