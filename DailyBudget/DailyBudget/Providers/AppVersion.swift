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
  
  init?(intValue: Int?) {
    guard let intValue = intValue else { return nil }
    self.major = intValue / 1000000
    self.minor = intValue / 1000 - (self.major * 1000)
    self.build = intValue - (self.major * 1000000) - (self.minor * 1000)
  }
  
  let major: Int
  let minor: Int
  let build: Int
  
  var intValue: Int {
    major * 1000000 + minor * 1000 + build
  }
  
  var stringValue: String {
    "\(major).\(minor) (\(build))"
  }
}

extension AppVersion: Equatable {}
