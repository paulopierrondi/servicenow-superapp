import SwiftUI

enum AppTab: Hashable {
  case home
  case payments
  case security
  case support
  case now

  var titleKey: LocalizedStringKey {
    switch self {
    case .home: return "tab.home"
    case .payments: return "tab.payments"
    case .security: return "tab.security"
    case .support: return "tab.support"
    case .now: return "tab.now"
    }
  }

  var symbolName: String {
    switch self {
    case .home: return "house.fill"
    case .payments: return "qrcode.viewfinder"
    case .security: return "shield.lefthalf.filled"
    case .support: return "bubble.left.and.bubble.right.fill"
    case .now: return "rectangle.3.group.bubble.left.fill"
    }
  }

  init(route: AppRoute) {
    switch route {
    case .home: self = .home
    case .payments: self = .payments
    case .security: self = .security
    case .support: self = .support
    case .profile: self = .now
    case .now: self = .now
    }
  }
}

struct RootView: View {
  @StateObject private var authSession = AuthSession()
  @StateObject private var featureFlags = FeatureFlagStore()
  @StateObject private var homeViewModel = HomeViewModel()

  @State private var selectedTab: AppTab = .home

  private let deepLinkRouter = DeepLinkRouter()

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView(selectedTab: $selectedTab)
        .tabItem { Label(AppTab.home.titleKey, systemImage: AppTab.home.symbolName) }
        .tag(AppTab.home)

      PaymentsView()
        .tabItem { Label(AppTab.payments.titleKey, systemImage: AppTab.payments.symbolName) }
        .tag(AppTab.payments)

      SecurityView()
        .tabItem { Label(AppTab.security.titleKey, systemImage: AppTab.security.symbolName) }
        .tag(AppTab.security)

      SupportView()
        .tabItem { Label(AppTab.support.titleKey, systemImage: AppTab.support.symbolName) }
        .tag(AppTab.support)

      NowOperationsView(selectedTab: $selectedTab)
        .tabItem { Label(AppTab.now.titleKey, systemImage: AppTab.now.symbolName) }
        .tag(AppTab.now)
    }
    .accentColor(BankTheme.Palette.brandRed)
    .environmentObject(authSession)
    .environmentObject(featureFlags)
    .environmentObject(homeViewModel)
    .task {
      await homeViewModel.load()
      featureFlags.update(homeViewModel.home.featureFlags)
    }
    .onOpenURL { url in
      guard let route = deepLinkRouter.route(for: url) else { return }
      selectedTab = AppTab(route: route)
    }
  }
}
