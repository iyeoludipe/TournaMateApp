import Foundation

struct Team: Identifiable {
    var id: String
    var name: String
    var players: Int

    init(id: String = UUID().uuidString, name: String = "", players: Int = 0) {
        self.id = id
        self.name = name
        self.players = players
    }
}

