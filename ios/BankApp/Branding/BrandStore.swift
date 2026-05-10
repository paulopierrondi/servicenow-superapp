import Combine
import Foundation

final class BrandStore: ObservableObject {
  private let userDefaults: UserDefaults

  @Published private(set) var selectedBrand: AppBrand?

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
    selectedBrand = userDefaults.string(forKey: AppBrand.selectionDefaultsKey)
      .flatMap { AppBrand(rawValue: $0.lowercased()) }
  }

  var hasSelection: Bool {
    selectedBrand != nil
  }

  var effectiveBrand: AppBrand {
    selectedBrand ?? AppBrand.resolve(userDefaults: userDefaults)
  }

  func select(_ brand: AppBrand) {
    userDefaults.set(brand.rawValue, forKey: AppBrand.selectionDefaultsKey)
    selectedBrand = brand
  }

  func resetSelection() {
    userDefaults.removeObject(forKey: AppBrand.selectionDefaultsKey)
    selectedBrand = nil
  }
}
