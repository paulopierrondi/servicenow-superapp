# Makefile — gate de Definition of Done para agentes e humanos.
#
# Uso:
#   make verify          → roda lint, build, test, contract tests
#   make ios-build       → build iOS Debug
#   make ios-test        → testes iOS
#   make ios-lint        → SwiftLint estrito
#   make xcode           → regenera .xcodeproj a partir de project.yml
#   make mock-harness-run → sobe mock harness localmente
#   make contract-test   → roda contract tests contra mock harness

.PHONY: help verify xcode ios-build ios-test ios-lint mock-harness-run \
        mock-harness-stop contract-test diagrams clean install-tools

IOS_SIMULATOR ?= iPhone 17
IOS_BUILD_DESTINATION ?= generic/platform=iOS Simulator
IOS_TEST_DESTINATION ?= platform=iOS Simulator,name=$(IOS_SIMULATOR),OS=latest

help:
	@echo "Targets:"
	@echo "  verify              - DoD gate: lint + build + test + contract"
	@echo "  xcode               - regenerar Xcode project (XcodeGen)"
	@echo "  ios-build           - build iOS Debug"
	@echo "  ios-test            - test iOS"
	@echo "  ios-lint            - SwiftLint --strict"
	@echo "  mock-harness-run    - subir mock harness em :8080"
	@echo "  mock-harness-stop   - parar mock harness"
	@echo "  contract-test       - testes de contrato"
	@echo "  diagrams            - validar diagramas Mermaid"
	@echo "  install-tools       - instalar XcodeGen, SwiftLint, mmdc"

install-tools:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew necessário"; exit 1; }
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	@command -v swiftlint >/dev/null 2>&1 || brew install swiftlint
	@command -v mmdc >/dev/null 2>&1 || npm install -g @mermaid-js/mermaid-cli

xcode:
	cd ios && xcodegen generate

ios-lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		cd ios && swiftlint --strict; \
	else \
		cd ios && xcrun swift-format lint --recursive --strict BankApp BankAppTests BankAppUITests; \
	fi

ios-build: xcode
	cd ios && xcodebuild \
		-project BankApp.xcodeproj \
		-scheme BankApp-Dev \
		-configuration Debug \
		-destination '$(IOS_BUILD_DESTINATION)' \
		-derivedDataPath build \
		-quiet \
		CODE_SIGNING_ALLOWED=NO \
		build
	cd ios && xcodebuild \
		-project BankApp.xcodeproj \
		-scheme BankApp-Itau-Dev \
		-configuration Debug \
		-destination '$(IOS_BUILD_DESTINATION)' \
		-derivedDataPath build \
		-quiet \
		CODE_SIGNING_ALLOWED=NO \
		build

ios-test: xcode
	cd ios && xcodebuild \
		-project BankApp.xcodeproj \
		-scheme BankApp-Dev \
		-configuration Debug \
		-destination '$(IOS_TEST_DESTINATION)' \
		-derivedDataPath build \
		-quiet \
		CODE_SIGNING_ALLOWED=NO \
		test

mock-harness-run:
	cd railway/services/mock-harness && \
		( npm install --omit=dev || npm install ) && \
		( pkill -f "node server.js" 2>/dev/null || true ) && \
		( node server.js & echo $$! > .pid ) && \
		sleep 2 && \
		curl -fsS http://localhost:8080/health

mock-harness-stop:
	@if [ -f railway/services/mock-harness/.pid ]; then \
		kill `cat railway/services/mock-harness/.pid` 2>/dev/null || true; \
		rm railway/services/mock-harness/.pid; \
	fi

contract-test: mock-harness-run
	@echo "Running contract tests..."
	@curl -fsS \
		-H "X-Client-Version: 0.1.0" \
		-H "X-Client-Schema-Version: 2026-05-home-v1" \
		-H "X-Client-Platform: ios" \
		http://localhost:8080/api/x_bank/v1/mobile-home > /dev/null && \
		echo "✓ mobile-home v1" || (echo "✗ mobile-home v1"; exit 1)
	@curl -fsS \
		-H "X-Client-Version: 0.1.0" \
		-H "X-Client-Schema-Version: 2026-05-work-v1" \
		-H "X-Client-Platform: ios" \
		http://localhost:8080/api/x_bank/v1/mobile-work > /dev/null && \
		echo "✓ mobile-work v1" || (echo "✗ mobile-work v1"; exit 1)
	@$(MAKE) mock-harness-stop

diagrams:
	@for f in docs/diagrams/*.mmd; do \
		if [ -f "$$f" ]; then \
			echo "Validating $$f..."; \
			mmdc -i "$$f" -o /tmp/diagram.svg 2>&1 | grep -i error && exit 1 || true; \
		fi; \
	done
	@echo "✓ all diagrams valid"

verify: ios-lint ios-build ios-test contract-test diagrams
	@echo ""
	@echo "✓ Definition of Done gate verde."

clean:
	rm -rf ios/build ios/BankApp.xcodeproj
	rm -rf railway/services/*/node_modules railway/services/*/dist
	$(MAKE) mock-harness-stop
