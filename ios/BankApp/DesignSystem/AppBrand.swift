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
    case .bradesco: return Color(bankHex: 0x970020)
    case .itau: return Color(bankHex: 0xB34A00)
    }
  }

  var accentColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x3F73B8)
    case .itau: return Color(bankHex: 0x003399)
    }
  }

  var chromeColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x4778BC)
    case .itau: return primaryColor
    }
  }

  var chromeDarkColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x064D93)
    case .itau: return Color(bankHex: 0xD45D00)
    }
  }

  var actionColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0xCC092F)
    case .itau: return accentColor
    }
  }

  var appBackground: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0xF4F8FD)
    case .itau: return Color(bankHex: 0xFFF7EF)
    }
  }

  var surfaceColor: Color {
    Color(bankHex: 0xFFFFFF)
  }

  var subtleSurfaceColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0xEDF4FC)
    case .itau: return Color(bankHex: 0xFFF0E1)
    }
  }

  var commandSurfaceColor: Color {
    switch self {
    case .bradesco: return Color(bankHex: 0x082E58)
    case .itau: return Color(bankHex: 0x06235F)
    }
  }

  var universalLinkHost: String {
    switch self {
    case .bradesco: return "m.bradesco.com.br"
    case .itau: return "m.itau.com.br"
    }
  }
}
