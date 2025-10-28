# 🔐 SafeKey — Gerenciador de Senhas

Aplicativo Flutter integrado ao Firebase para **gerar, armazenar e gerenciar senhas fortes**.  
Desenvolvido como parte do Checkpoint de Flutter — 2º semestre.

Link da apresentação do projeto:
https://youtu.be/AO7LNAlbbAI

---

## 🚀 Funcionalidades

- 🔑 **Autenticação com Firebase Auth**
- ☁️ **Armazenamento no Firestore**
- ⚙️ **Geração de senhas pela API externa (com fallback local)**
- 🧭 **Tela de introdução com animações Lottie**
- 📱 **Design responsivo e leve (Material 3)**
- 🔒 **Controle individual de visibilidade e cópia de senhas**
- ✨ **Tema visual limpo com animações**

---

## 🛠️ Tecnologias utilizadas

| Stack | Descrição |
|-------|------------|
| **Flutter 3.24+** | Framework principal |
| **Firebase Core / Auth / Firestore** | Backend e autenticação |
| **HTTP** | Comunicação com API externa |
| **Lottie** | Animações nas telas |
| **Shared Preferences** | Armazena preferências locais (Intro) |

---

## 📂 Estrutura de pastas

```
lib/
├── main.dart
├── firebase_options.dart
├── screens/
│   ├── splash_screen.dart
│   ├── intro_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── new_password_screen.dart
├── services/
│   ├── firestore_service.dart
│   ├── password_api_service.dart
│   └── preferences_service.dart
├── widgets/
│   └── custom_text_field.dart
assets/
├── lottie/
│   ├── splash.json
│   ├── intro1.json
│   ├── intro2.json
│   ├── intro3.json
│   └── premium.json
└── images/
    └── logo.png
```

---

## 🔧 Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
2. Ative **Authentication (Email/Senha)** e **Cloud Firestore**.
3. Execute no terminal dentro do projeto:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. Adicione as **regras de segurança**:
   ```js
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/passwords/{docId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

---

## 🔗 Integração com API de geração de senhas

O app utiliza a API pública:
```
POST https://safekey-api-a1bd9aa97953.herokuapp.com/generate
Content-Type: application/json
{
  "length": 12,
  "includeLowercase": true,
  "includeUppercase": true,
  "includeNumbers": true,
  "includeSymbols": true
}
```

Caso a API esteja indisponível, o app faz a geração local de senhas automaticamente.

---

## 👥 Integrantes

| Nome | RM |
|------|----|
| Felipe Cardoso | RM99062 |
| Carlos Augusto | RM98456 |

---

## 📸 Pré-visualização (sugestão)
- Tela de Splash com Lottie (`splash.json`)
- Intro com 3 animações (`intro1-3.json`)
- Login com FirebaseAuth
- Home com senhas armazenadas e banner premium (`premium.json`)
- Nova senha → geração via API e salvamento no Firestore

---

## 🧩 Comandos úteis

```bash
flutter pub get          # Instala dependências
flutter run              # Executa o app
flutter clean            # Limpa cache
flutterfire configure    # Vincula o Firebase
```

---

## 🧠 Observação
O projeto foi desenvolvido com foco em boas práticas de organização, UX limpo e integração entre camadas.  
Todo o código está comentado para facilitar a explicação durante a avaliação.
