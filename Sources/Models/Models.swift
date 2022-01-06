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

extension Meditation {
    public var durationFormatted: String? {
        get {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
            formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
            formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale

            return  formatter.string(from: self.duration)
        }
    }
}
