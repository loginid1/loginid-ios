# LoginIDAuth

The **LoginIDAuth** Swift package is the main entry point for the LoginID SDK, offering a comprehensive suite of authentication services. It provides all the necessary tools for passkey-based authentication, one-time passwords (OTP), transaction confirmation, and passkey management, serving as a standalone solution for developers.

## Features

- 🔑 **Passkey Authentication & Creation**: Sign in or create passkeys for your users with WebAuthn-compatible authentication.
- 📱 **Transaction Confirmation**: Securely confirm transactions or sensitive actions using passkeys.
- 📩 **One-Time Passwords (OTP)**: Request and validate OTPs as a fallback authentication method.
- 🛠️ **Passkey Management**: Allow users to list, rename, and delete their passkeys.
- ⚙️ **Configuration & Session Utilities**: Verify SDK setup and manage user sessions with ease.

## Requirements

- iOS 16.0+
- xcode 16.0+
- Swift 6.0+

## Installation

You can integrate the **LoginIDAuth** in these ways:

### Add via Xcode (Paste GitHub URL) Via Swift Package Manager

1. In Xcode, open your project.
2. Go to **File → Add Packages….**
3. In the search bar, paste:
```
https://github.com/loginid/LoginIDSwiftSDK.git
```
4. Select the target(s) where you want to add the SDK and click **Add Package**.

### Swift Package Manager in `Package.swift`

If you manage dependencies manually in `Package.swift`, add:

```swift
dependencies: [
    .package(url: "https://github.com/loginid1/loginid-ios", from: "2.0.0")
]
```

Then, in the target that needs the SDK:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "LoginIDAuth", package: "LoginIDAuth")
    ]
)
```

Finally, run:

```bash
swift package update
```

## How to Use

### Setup

```swift
import LoginIDAuth

@main
struct MyApp: App {
  private let lid: LoginIDAuth
    
  init() {
    let baseUrl = "<YOUR_BASE_URL>"
    self.lid = LoginIDAuth(baseUrl: baseUrl)
      
    // Other setup code...
  }
}
```

### Create a passkey

```swift
import LoginIDAuth

private func createPasskey() async {
    do {
        let username = "user@example.com"
        let result = try await lid.createPasskey(username: username)
        if result.isAuthenticated {
            print("Passkey created and user authenticated. Token: \(result.token ?? "N/A")")
        }
    } catch let error as LoginIDError {
        print("Error creating passkey: \(error.message)")
    }
}
```

### Authenticate with a passkey

```swift
import LoginIDAuth

private func authenticateWithPasskey() async {
    do {
        let username = "user@example.com"
        let result = try await lid.authenticateWithPasskey(username: username)
        if result.isAuthenticated {
            print("User authenticated with passkey. Token: \(result.token ?? "N/A")")
        } else if result.isFallback, let options = result.fallbackOptions {
            print("Fallback options available: \(options)")
            // Handle fallback (e.g., OTP)
        }
    } catch let error as LoginIDError {
        print("Error authenticating with passkey: \(error.message)")
    }
}
```

<details>
<summary>Authenticate with passkey autofill</summary>

```swift
import LoginIDAuth

private func authenticateWithAutofill() async {
    do {
        let result = try await lid.authenticateWithPasskeyAutofill()
        if result.isAuthenticated {
            print("User authenticated with passkey autofill. Token: \(result.token ?? "N/A")")
        }
    } catch let error as LoginIDError {
        print("Error authenticating with passkey autofill: \(error.message)")
    }
}
```
</details>

<details>
<summary>Confirm a transaction</summary>

```swift
import LoginIDAuth

private func confirmTransaction() async {
    do {
        let username = "user@example.com"
        let payload = "{ \"amount\": 100, \"currency\": \"USD\" }"
        let result = try await lid.confirmTransaction(username: username, txPayload: payload)
        print("Transaction confirmed. Token: \(result.token)")
    } catch let error as LoginIDError {
        print("Error confirming transaction: \(error.message)")
    }
}
```
</details>

<details>
<summary>List passkeys</summary>

```swift
import LoginIDAuth

private func listPasskeys() async {
    do {
        // Assume user is already authenticated and you have an authzToken
        // from a previous createPasskey or authenticateWithPasskey call.
        let authzToken = "user-auth-token" 
        let passkeys = try await lid.listPasskeys(authzToken: authzToken)
        print("User has \(passkeys.count) passkeys.")
        for passkey in passkeys {
            print("- Passkey ID: \(passkey.id)")
        }
    } catch let error as LoginIDError {
        print("Error listing passkeys: \(error.message)")
    }
}
```
</details>

## Contact and Support

- **Email**: support@loginid.io
- **Documentation**: https://docs.loginid.io
- **Forum**: https://forum.loginid.dev
- **Bug Reports**: https://loginid.dev
- **Dashboard**: https://dashboard.loginid.io

## License

This project is licensed under the Apache 2.0 License. See LICENSE.md for details.
