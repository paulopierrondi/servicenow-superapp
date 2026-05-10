import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
  @Published private(set) var home: MobileHomeResponse
  @Published private(set) var snapshot: AccountSnapshot
  @Published private(set) var transactions: [TransactionItem]
  @Published private(set) var insights: [SmartInsight]
  @Published private(set) var isLoading: Bool

  private let serviceNowClient: ServiceNowClienting

  init(
    serviceNowClient: ServiceNowClienting = ServiceNowClient(),
    home: MobileHomeResponse = .demo,
    snapshot: AccountSnapshot = .demo,
    transactions: [TransactionItem] = TransactionItem.demo,
    insights: [SmartInsight] = SmartInsight.demo
  ) {
    self.serviceNowClient = serviceNowClient
    self.home = home
    self.snapshot = snapshot
    self.transactions = transactions
    self.insights = insights
    self.isLoading = false
  }

  var visibleHomeCards: [HomeCardDTO] {
    home.cards.filter { card in
      home.featureFlags.isEnabled(card.requiresFlag)
    }
  }

  func load() async {
    isLoading = true
    defer { isLoading = false }

    do {
      home = try await serviceNowClient.fetchHome()
    } catch {
      home = .demo
    }
  }
}
