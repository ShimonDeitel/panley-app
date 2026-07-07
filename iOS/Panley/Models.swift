import Foundation

struct ItemEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Int
    var expiryDate: Date
    var location: String

    init(id: UUID = UUID(), name: String = "", quantity: Int = 0, expiryDate: Date = Date(), location: String = "") {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.location = location
    }
}
