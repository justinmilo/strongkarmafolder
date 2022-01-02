import Foundation

public struct Meditation : Hashable, Identifiable, Codable, Equatable {
    public var id : UUID
    public var date : String
    public var duration : Double
    public var entry : String
    public var title : String
    public init(id : UUID,
                date : String,
                duration : Double,
                entry : String,
                title : String) {
        self.id = id
        self.date = date
        self.duration = duration
        self.entry = entry
        self.title = title
    }
}
