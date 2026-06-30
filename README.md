# loginid-ios

Monorepo for LoginID's Gen3 iOS SDKs. This repository contains native Swift SDKs for integrating passwordless
authentication, passkey support, and multi-factor authentication (MFA) into iOS applications.

## Structure

```
LoginIDAuth                 # Native iOS SDK for standalone passkey authentication
LoginIDCore                 # Shared utilities and core logic for all SDKs
LoginIDMFA                  # Native iOS SDK for passwordless + MFA
LoginIDWalletAuth           # Native iOS SDK for specialized wallet-based passkey authentication
```

## Packages Overview 

### LoginIDAuth

**LoginIDAuth** is the main entry point for the LoginID SDK, offering a comprehensive suite of authentication services. It provides all the necessary tools for passkey-based authentication, one-time passwords (OTP), transaction confirmation, and passkey management, serving as a standalone solution for developers.

---

### LoginIDCore

Common, reusable utilities and core logic used across all SDKs.

---

### LoginIDMFA

**LoginIDMFA** is a Swift package for secure MFA on iOS, supporting passkeys, OTP, and external providers.
It also manages sessions, device trust, and underpins other packages.

---

### LoginIDWalletAuth

**LoginIDWalletAuth** is a Swift package for iOS apps that combines MFA and identity trust in checkout flows.
Built on **LoginIDMFA**, it’s optimized for passkey-based transaction confirmation.

---

## Contact and Support

- **Email**: support@loginid.io
- **Documentation**: https://docs.loginid.io
- **Forum**: https://forum.loginid.dev
- **Bug Reports**: https://loginid.dev
- **Dashboard**: https://dashboard.loginid.io

## License

This project is licensed under the Apache 2.0 License. See LICENSE.md for details.
