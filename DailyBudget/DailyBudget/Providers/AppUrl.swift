import Foundation

/// Safe types representing valid in-app URL destinations
enum AppUrl {
  case viewBudget(uuid: String)
}

// MARK: To URL -

extension AppUrl {
  var url: URL? {
    switch self {
    case .viewBudget(let uuid):
      var components = URLComponents()
      components.scheme = scheme
      components.path = budgetPath
      components.queryItems = [URLQueryItem(name: budgetIdKey, value: uuid)]
      return components.url
    }
  }
}

// MARK: From URL -

extension AppUrl {
  init?(_ url: URL) {
    guard
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      components.scheme == scheme,
      components.path == budgetPath,
      let queryItem = components.queryItems?.first(where: { $0.name == budgetIdKey }),
      let uuid = queryItem.value
    else { return nil }
    
    self = .viewBudget(uuid: uuid)
  }
}

// MARK: Constants -

private let scheme: String = "dailybudget"
private let budgetPath: String = "budget"
private let budgetIdKey: String = "uuid"
