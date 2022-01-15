import Foundation
import Models
import Parsing
import ParsingHelpers

public enum EditEntryRoute {
    case title
    case body
//  case row(Item.ID, ItemRowRoute)
}

public let itemRowDeepLinker = PathComponent("title")
  .skip(PathEnd())
  .map { EditEntryRoute.title }
  .orElse(
    PathComponent("body")
      .skip(PathEnd())
      .map { .body }
  )

extension EditEntryView {
  public func navigate(to route: EditEntryRoute?) {
  }
}
