# LoginIDMFA

The **LoginIDMFA** Swift package provides a flexible and secure multi-factor authentication (MFA) flow for iOS
applications. It is designed to handle the following authentication factors:

- passkeys
- one-time passwords (OTP)
- external identity providers

It also managing session persistence and device trust.

This SDK serves as the foundation for higher-level flows (such as **LoginIDWalletAuth**) and can be integrated
directly for full control over MFA experiences.

## Features

- 🔑 **Passkey Authentication & Creation** – WebAuthn-compatible authentication for passwordless sign-in.
- 📩 **OTP over Email & SMS** – Send and verify OTPs for additional authentication factors.
- 🌐 **External Authentication Support** – Plug in third-party identity providers (e.g., bank logins).
- 🔄 **Session & Device Trust Management** – Automatically manages secure sessions and trusted device identifiers across MFA flows.
- ⚡ **Flexible MFA Flow Control** – Start MFA sessions, perform actions, and progress through required factors.

## Requirements

- iOS 16.0+
- xcode 16.0+
- Swift 6.0+

## Installation

You can integrate the **LoginIDMFA** in these ways:

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
    .package(url: "https://github.com/loginid1/LoginIDMFA.git", from: "1.0.0")
]
```

Then, in the target that needs the SDK:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "LoginIDMFA", package: "LoginIDMFA")
    ]
)
```

Finally, run:

```bash
swift package update
```

## Contact and Support

- **Email**: support@loginid.io
- **Documentation**: https://docs.loginid.io
- **Forum**: https://forum.loginid.dev
- **Bug Reports**: https://loginid.dev
- **Dashboard**: https://dashboard.loginid.io

## License

This project is licensed under the Apache 2.0 License. See LICENSE.md for details.
