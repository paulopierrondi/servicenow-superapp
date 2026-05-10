# ADR-013 — Deep linking bidirecional entre nativo e branded

**Status:** Proposto  
**Data:** 2026-05-10  
**Owner:** Paulo Henrique Carneiro Pierrondi  
**LGPD:** payload de deep link contém identificador de cliente (pseudonimizado); base legal: execução de contrato + legítimo interesse no atendimento  
**CMN 4.893/2021:** trilha de auditoria do handoff fica na instância (`x_bank_session_log`)  
**Open Finance Brasil:** não aplicável diretamente; consent OFB segue fluxo próprio

## Contexto

Cliente em jornada no app nativo pode precisar continuar com atendente humano (companion branded), e vice-versa. Sem um modelo de handoff seguro, o atendente perde contexto e o cliente repete informação. Isso gera support debt e fricção.

## Decisão

Adotar dois canais de deep linking:

### Canal 1 — Universal Links (preferencial)

- Domínio: `m.bradesco.com.br` (prod), `m-staging.bradesco.com.br` (staging).
- Apple App Site Association (`apple-app-site-association`) hospedado no domínio com paths permitidos.
- Funciona mesmo se o app não estiver instalado (web fallback).

### Canal 2 — Custom URL schemes (fallback)

- Nativo: `bradesco-app://` (prod), `bradesco-app-dev://`, `bradesco-app-staging://`, `bradesco-app-demo://`.
- Branded: `bradesco-atendimento://`.
- Now Mobile (referência): `now-mobile://`.

### Payload assinado

Todo deep link com contexto sensível (jornada, customer ID, step) carrega payload assinado:

```json
{
  "subject_customer_id": "pseudo:abc123",
  "journey_id": "pix-2026-05-10-XYZ",
  "step": "review_recipient",
  "issued_at": "2026-05-10T15:30:00Z",
  "expires_at": "2026-05-10T15:35:00Z",
  "signed_payload": "<HMAC-SHA256 base64url>"
}
```

- Assinatura HMAC-SHA256 com **secret rotativo armazenado na instância** (rotação semanal).
- Validação obrigatória contra `/api/x_bank/v1/deep-link-validate` antes de renderizar a tela alvo.
- TTL máximo 5 minutos. Expirado → tela de "sessão expirada, refaça login".

## Consequências

✅ Handoff sem perda de contexto.  
✅ Auditoria centralizada na instância.  
✅ Resistente a ataque de replay (TTL curto + secret rotativo).

⚠️ Custom schemes podem ser sequestrados por outros apps; preferir universal links sempre que possível.  
⚠️ Validação síncrona contra a instância aumenta latência. Mitigação: cache de chave pública para verificação local quando assinatura permitir (decisão pendente).

❌ Nunca passar PII em claro no deep link. Sempre pseudonimizar `subject_customer_id`.  
❌ Nunca aceitar deep link sem validação de assinatura.

## Decision gates

- DEC-203: HMAC vs JWT (favor HMAC simétrico para baixa latência; JWT se quiser revogação granular).
- DEC-213: cache de chave para validação local (acelera UX, complica revogação).
- DEC-214: política de rotação do secret (semanal vs trigger-based).

## Implementação inicial

```swift
// ios/BankApp/DeepLink/DeepLinkRouter.swift
enum DeepLinkRoute {
    case home
    case payment(paymentId: String)
    case journey(payload: DeepLinkPayload)
    case unknown(URL)
}

struct DeepLinkPayload: Codable {
    let subjectCustomerId: String
    let journeyId: String
    let step: String
    let issuedAt: Date
    let expiresAt: Date
    let signedPayload: String
}

protocol DeepLinkValidating {
    func validate(_ payload: DeepLinkPayload) async throws -> Bool
}

final class DeepLinkRouter {
    private let validator: DeepLinkValidating
    init(validator: DeepLinkValidating) { self.validator = validator }

    func route(_ url: URL) async -> DeepLinkRoute {
        guard let route = parse(url) else { return .unknown(url) }
        if case .journey(let payload) = route {
            do {
                let ok = try await validator.validate(payload)
                guard ok else { return .home }
            } catch {
                return .home
            }
        }
        return route
    }

    private func parse(_ url: URL) -> DeepLinkRoute? {
        // TODO: implementar parsing universal link + custom scheme
        return nil
    }
}
```

## Referências

- AGENTS.md §2 ADR-013.
- docs/integration-with-now-mobile.md §4.
