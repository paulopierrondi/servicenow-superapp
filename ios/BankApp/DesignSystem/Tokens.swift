import SwiftUI

enum BankTheme {
  enum Palette {
    static var appBackground: Color { AppBrand.current.appBackground }
    static var surface: Color { AppBrand.current.surfaceColor }
    static var subtleSurface: Color { AppBrand.current.subtleSurfaceColor }
    static let elevatedSurface = Color(bankHex: 0xFFFFFF)
    static var brandPrimary: Color { AppBrand.current.primaryColor }
    static var brandPrimaryDark: Color { AppBrand.current.primaryDarkColor }
    static var brandRed: Color { brandPrimary }
    static var brandRedDark: Color { brandPrimaryDark }
    static var brandSecondary: Color { AppBrand.current.accentColor }
    static var brandAccent: Color { brandSecondary }
    static var brandChrome: Color { AppBrand.current.chromeColor }
    static var brandChromeDark: Color { AppBrand.current.chromeDarkColor }
    static var brandAction: Color { AppBrand.current.actionColor }
    static let ink = Color(bankHex: 0x1C1C1E)
    static let secondaryInk = Color(bankHex: 0x636366)
    static let mutedInk = Color(bankHex: 0x8E8E93)
    static let divider = Color(bankHex: 0xD1D1D6)
    static let success = Color(bankHex: 0x34C759)
    static let warning = Color(bankHex: 0xFF9500)
    static let attention = Color(bankHex: 0x007AFF)
    static let secure = Color(bankHex: 0x30D158)
    static var graphite: Color { AppBrand.current.commandSurfaceColor }
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
    static let display = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.bold)
    static let section = Font.title3.weight(.semibold)
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body
    static let callout = Font.callout.weight(.medium)
    static let caption = Font.footnote.weight(.semibold)
    static let micro = Font.caption.weight(.semibold)
    static let amount = Font.title.weight(.bold)
    static let metric = Font.title3.weight(.bold)
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
