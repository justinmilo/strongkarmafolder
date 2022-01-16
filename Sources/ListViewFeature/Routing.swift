import Foundation
import Models
import Parsing
import ParsingHelpers

public enum ListRoute {
    case add(Meditation, ItemRoute? = nil)
    case timed
//  case row(Item.ID, ItemRowRoute)
}

public enum ItemRoute {
  case colorPicker
}

public let listDeepLinker = PathEnd()

extension ListViewState {
    public mutating func navigate(to route: ListRoute?) {
    switch route {
    case .none:
      self.route = nil
    case .some(_):
        return
    }
  }
}
