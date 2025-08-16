# LoginIDWalletAuth

The **LoginIDWalletAuth** Swift package provides a specialized authentication flow for iOS apps that require both
multi-factor authentication (MFA) and identity trust during checkout scenarios. It is built on top of [**LoginIDMFA**](../LoginIDMFA/)
and optimized for passkey-based transaction confirmation.

## Features

- 🔑 **Passkey Authentication & Creation** – Sign in or create passkeys for your users with WebAuthn-compatible authentication.
- 🛒 **Checkout-Specific MFA Flows** – Bind MFA sessions to transaction payloads for purchase confirmations.
- 🔄 **Flexible Action Execution** – Perform actions such as passkey authentication, registration, transaction confirmation, or external auth.

## Requirements

- iOS 16.0+
- xcode 16.0+
- Swift 6.0+

## Installation

You can integrate the **LoginIDWalletAuth** in these ways:

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
    .package(url: "https://github.com/loginid1/LoginIDWalletAuth.git", from: "1.0.0")
]
```

Then, in the target that needs the SDK:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "LoginIDWalletAuth", package: "LoginIDWalletAuth")
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
@main
struct MyApp: App {
  let private lid: LoginIDWalletAuth
    
  init() {
    let baseUrl = "<YOUR_BASE_URL>"
    self.lid = LoginIDWalletAuth(baseUrl: baseUrl)
      
    // Other setup code...
  }
}

```

### On Component Mount

Call `beginFlow` when your screen loads to start an MFA session.
The response tells you whether the user can confirm the transaction directly with a passkey, or if they need to
sign in first.

```swift
import LoginIDWalletAuth

private func startMFAFlow() async {
    do {
        // 1. Start MFA session for this checkout
        let flow = BeginFlowOptions(txPayload: "{ \"amount\": 100 }")
        let session = try await lid.beginFlow(flow)

        // 2. Decide what UI to show next
        switch session.nextAction {
        case .passkeyTx:
            // User can confirm the transaction with a passkey → show checkout UI
        case .passkeyAuth:
            // User needs to log in with a passkey or a third-party (e.g. bank login) → show login UI
        default:
            // Handle other cases
        }
    } catch let error as LoginIDError {
        print("Error starting MFA flow: \(error.message)")
    }
}
```

<details>
<summary>Add passkey after bank or third-party login</summary>

Once your backend has verified a user’s login with a bank or third party, return a LoginID authorization token.

```swift
import LoginIDWalletAuth

private func handleBankLogin() async {
    do {
        // 1. Verify login with your backend
        let authToken = try await MyBackend.verifyBankLogin()

        // 2. Confirm external login with the token
        let updated = try await lid.performAction(
            .external,
            options: PerformActionOptions(payload: authToken),
        )

        // 3. If prompted, register a passkey
        if updated.nextAction == .passkeyReg {
            _ = try await lid.performAction(.passkeyReg)
        }
    } catch let error as LoginIDError {
        print("Error with MFA flow: \(error.message)")
    }
}
```
</details>

<details>
<summary>Wallet signin with a passkey</summary>

On the login screen, if beginFlow indicates `.passkeyAuth`, let the user sign in with their passkey:

```swift
import LoginIDWalletAuth

private func walletSignIn() async {
    do {
        // BeginFlow returned `.passkeyAuth`
        let result = try await lid.performAction(.passkeyAuth)
        print("Wallet user signed in")
    } catch let error as LoginIDError {
        print("Error signing in with passkey: \(error.message)")
    }
}
```
</details>

<details>
<summary>Wallet signin with passkey autofill</summary>

On the login screen, you can trigger passkey autofill as soon as the view loads and wait for the user to complete it:

```swift
import LoginIDWalletAuth

private func autoFillWalletSignIn() async {
    do {
        // BeginFlow returned `.passkeyAuth`
        let options = PerformActionOptions(autoFill: true)
        let signedInSession = try await lid.performAction(.passkeyAuth, options: options)
        print("Wallet user signed in with autofill")
    } catch let error as LoginIDError {
        print("Error signing in with passkey autofill: \(error.message)")
    }
}
```
</details>

<details>
<summary>Confirm payment with a passkey</summary>

If beginFlow returned `.passkeyTx`, show the checkout page and let the user confirm the payment directly with their passkey.
This acts as both a sign-in and payment confirmation in one step:

```swift
private func confirmPayment() async {
    do {
        // BeginFlow returned `.passkeyTx`
        let signedInSession = try await lid.performAction(.passkeyTx)
        print("Wallet user confirmed payment")
    } catch let error as LoginIDError {
        print("Error signing in with passkey autofill: \(error.message)")
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
