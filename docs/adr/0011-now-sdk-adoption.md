# ADR-011 — Adoção do NowSDK no app nativo iOS

**Status:** Proposto  
**Data:** 2026-05-10  
**Owner:** Paulo Henrique Carneiro Pierrondi  
**LGPD:** alto impacto — telemetria pode capturar PII; base legal: legítimo interesse + consentimento granular para chat NowAssist  
**CMN 4.893/2021:** aplicável — SDK consome serviços em nuvem da ServiceNow; documentar país de processamento  
**Open Finance Brasil:** não diretamente; mas consent flow via NowAssist deve respeitar perfil FAPI 1.0 quando OFB acionar

## Contexto

Para o app nativo Bradesco existir como extensão do ecossistema ServiceNow Mobile (e não app isolado), o NowSDK precisa ser embarcado. O SDK fornece telemetria unificada com a instância, NowAssist conversacional, theming consistente com Workspace mobile e companion branded, e services-of-platform.

A alternativa (zero NowSDK, só REST) força reescrever telemetria, chat AI, theming e cache de auth — dobrando o esforço e gerando divergência permanente de stack.

## Decisão

Adotar NowSDK no app nativo iOS, encapsulado por wrapper único em `ios/BankApp/NowSDKBridge/`. Acesso fora do bridge é proibido.

Fonte: SPM se a ServiceNow distribuir publicamente; senão, XCFramework local em `ios/Vendor/NowSDK.xcframework/`. Esta decisão de fonte é confirmada na Fase 3.

Configuração de instância vem exclusivamente de `Configs/{Env}.xcconfig`. Nada hardcoded.

## Consequências

✅ Continuidade de telemetria, chat e theming entre nativo, branded e Workspace.  
✅ Reduz esforço de reimplementação.  
✅ Habilita NowAssist como diferencial conversacional.

⚠️ Cria dependência de roadmap externo (versões, breaking changes).  
⚠️ Privacy manifest do NowSDK precisa convergir com `PrivacyInfo.xcprivacy` do app — revisar a cada upgrade.  
⚠️ Pinning e ATS precisam acomodar endpoints do SDK; lista mantida no xcconfig.

❌ Mobile impersonation do SDK fica banida — ADR-008.  
❌ Storage local default para PII bancária fica banido — usar Keychain próprio.

## Decision gates pendentes

- DEC-201: versão exata do NowSDK suportada para iOS 15+.
- DEC-211: forma de distribuição (SPM vs XCFramework).
- DEC-212: política de upgrade do SDK (cadência, regression suite).

## Referências

- AGENTS.md §2 ADR-011, §5 NowSDK.
- docs/integration-with-now-mobile.md §1.
- Relatório de pesquisa em `docs/research/deep-research-report_now_mobile.md`.
