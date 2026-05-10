import SwiftUI

enum BankTheme {
  enum Palette {
    static var appBackground: Color { AppBrand.current.appBackground }
    static var surface: Color { AppBrand.current.surfaceColor }
    static let elevatedSurface = Color(bankHex: 0xFFFFFF)
    static var brandPrimary: Color { AppBrand.current.primaryColor }
    static var brandPrimaryDark: Color { AppBrand.current.primaryDarkColor }
    static var brandRed: Color { brandPrimary }
    static var brandRedDark: Color { brandPrimaryDark }
    static let ink = Color(bankHex: 0x1C1A18)
    static let secondaryInk = Color(bankHex: 0x5D5751)
    static let mutedInk = Color(bankHex: 0x8C8378)
    static let divider = Color(bankHex: 0xE5DED4)
    static let success = Color(bankHex: 0x177A4D)
    static let warning = Color(bankHex: 0xC56B14)
    static let attention = Color(bankHex: 0x245B8F)
    static let secure = Color(bankHex: 0x2F6E5D)
    static var gold: Color { AppBrand.current.accentColor }
    static let graphite = Color(bankHex: 0x2B2A28)
  }

  enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 44
  }

  enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 18
    static let xl: CGFloat = 26
  }

  enum Stroke {
    static let hairline: CGFloat = 1
    static let focus: CGFloat = 2
  }

  enum Size {
    static let iconButton: CGFloat = 44
    static let iconBubble: CGFloat = 48
    static let compactIconBubble: CGFloat = 36
    static let actionTileHeight: CGFloat = 116
    static let tabHeroHeight: CGFloat = 186
    static let cardArtHeight: CGFloat = 112
    static let riskRing: CGFloat = 118
  }

  enum Typography {
    static let display = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .bold, design: .rounded)
    static let section = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 14, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let amount = Font.system(size: 32, weight: .bold, design: .rounded)
    static let metric = Font.system(size: 20, weight: .bold, design: .rounded)
  }
}

extension Color {
  init(bankHex: UInt, opacity: Double = 1) {
    let red = Double((bankHex >> 16) & 0xFF) / 255
    let green = Double((bankHex >> 8) & 0xFF) / 255
    let blue = Double(bankHex & 0xFF) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
