# Apps demo locais

Artefatos gerados por:

```bash
make demo-apps
```

## Arquivos

- `bradesco-servicenow-superapp-demo-simulator.zip`
- `itau-servicenow-superapp-demo-simulator.zip`

Os zips contêm `.app` de iOS Simulator, sem assinatura de App Store. Para instalar em um simulador iniciado:

```bash
ditto -x -k deliverables/apps/bradesco-servicenow-superapp-demo-simulator.zip /tmp/bradesco-demo-app
xcrun simctl install booted /tmp/bradesco-demo-app/BankApp.app
```

## Conexão padrão

Os apps demo apontam por padrão para:

```text
https://demoalectriallwfzbblp136802.service-now.com
```

Credenciais não são embutidas no app. O demo usa os endpoints publicados em `/api/x_bank/v1/...`.
