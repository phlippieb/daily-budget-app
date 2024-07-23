import Foundation

protocol AppVersionProvider {
  var appVersion: String? { get }
  var buildVersion: String? { get }
}

class DefaultAppVersionProvider: AppVersionProvider {
  var appVersion: String? {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  var buildVersion: String? {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String
  }
}

struct AppVersion {
  init?(from provider: AppVersionProvider = DefaultAppVersionProvider()) {
    guard
      let appString = provider.appVersion,
      let app = Double(appString),
      let minorString = appString.split(separator: ".").item(at: 1),
      let minor = Int(minorString),
      let buildString = provider.buildVersion,
      let build = Int(buildString)
    else { return nil }
    
    self.major = Int(app)
    self.minor = minor
    self.build = build
  }
  
  let major: Int
  let minor: Int
  let build: Int
  
  var stringValue: String {
    "\(major).\(minor) (\(build))"
  }
}

extension AppVersion: Equatable {}
