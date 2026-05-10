import SwiftUI

@main
struct BankAppApp: App {
  @StateObject private var brandStore = BrandStore()

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .environmentObject(brandStore)
    }
  }
}

private struct AppRootView: View {
  @EnvironmentObject private var brandStore: BrandStore

  private var skipsBrandSelection: Bool {
    ProcessInfo.processInfo.arguments.contains("-BankAppSkipBrandSelection")
  }

  var body: some View {
    Group {
      if brandStore.hasSelection || skipsBrandSelection {
        RootView()
          .id(brandStore.effectiveBrand.rawValue)
      } else {
        BrandSelectionView()
      }
    }
  }
}
