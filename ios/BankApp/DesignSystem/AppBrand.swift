import SwiftUI

enum AppBrand: String, CaseIterable, Equatable {
  case bradesco
  case itau

  static let selectionDefaultsKey = "selected_app_brand"

  static var current: AppBrand {
    resolve()
  }

  static func resolve(
    userDefaults: UserDefaults = .standard,
    environment: [String: String] = ProcessInfo.processInfo.environment,
    bundle: Bundle = .main
  ) -> AppBrand {
    if let rawValue = userDefaults.string(forKey: selectionDefaultsKey)?.lowercased(),
      let brand = AppBrand(rawValue: rawValue)
    {
      return brand
    }

    if let rawValue = environment["APP_BRAND"]?.lowercased(),
      let brand = AppBrand(rawValue: rawValue)
    {
      return brand
    }

    if let rawValue = bundle.object(forInfoDictionaryKey: "APP_BRAND") as? String,
      let brand = AppBrand(rawValue: rawValue.lowercased())
    {
      return brand
    }

    return .bradesco
  }

  var displayName: String {
    switch self {
    case .bradesco: return "Bradesco"
    case .itau: return "Itaú"
    }
  }

  var customerSegment: String {
    switch self {
    case .bradesco: return "Prime"
    case .itau: return "Personnalité"
    }
  }

  var relationshipManager: String {
    switch self {
    case .bradesco: return "Camila Andrade"
    case .itau: return "Marina Costa"
    }
  }

  var primaryColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0xCC092F)
    case .itau: return Color(bankHex: 0xEC7000)
    }
  }

  var primaryDarkColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x900F15)
    case .itau: return Color(bankHex: 0xB55400)
    }
  }

  var accentColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x900F15)
    case .itau: return Color(bankHex: 0x003399)
    }
  }

  var appBackground: Color {
    Color(bankHex: 0xF2F2F7)
  }

  var surfaceColor: Color {
    Color(bankHex: 0xFFFFFF)
  }

  var subtleSurfaceColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0xFFF1F4)
    case .itau: return Color(bankHex: 0xFFF4E9)
    }
  }

  var universalLinkHost: String {
    switch self {
    case .bradesco: return "m.bradesco.com.br"
    case .itau: return "m.itau.com.br"
    }
  }
}
