//
//  BeginFlowOptions.swift
//  LoginIDMFA
//
//  Created by Michael Braga on 2025-08-11.
//

import LoginIDAPIClient

/// Options for beginning Multi-Factor Authentication (MFA).
public struct BeginFlowOptions {
    /// A human-palatable name for the user account, intended only for display
    /// on your passkeys and modals.
    public let displayName: String?
    
    /// The type of username validation to be used.
    /// Defaults to `.other` and is omitted from the payload when `.other`.
    public let usernameType: UsernameType
    
    /// A string representing transaction details for confirmation during MFA.
    /// This can be plain text or a JSON-formatted string for structured details.
    ///
    /// Example (plain text):
    /// ```
    /// Payment of $100 to John Doe
    /// ```
    ///
    /// Example (JSON):
    /// ```json
    /// {
    ///   "transactionId": "12345",
    ///   "amount": "100.00",
    ///   "currency": "USD",
    ///   "recipient": "john.doe@example.com"
    /// }
    /// ```
    public let txPayload: String?
    
    /// Merchant-generated identifier for the current checkout session.
    /// Used as a key to retrieve associated trust information and link the session
    /// with wallet-issued identity data.
    public let merchantTrustId: String?
    
    /// A unique identifier used to trace and correlate all events associated with a single MFA interaction.
    /// If you don’t provide this, the server may generate one automatically.
    public let traceId: String?
    
    /// An identifier for the device used in the authentication process. This property helps determine if
    /// supported authentications can be proceeded, allowing future authentications to identify the device
    /// correctly.
    ///
    /// Overrides the stored device identifier. If not provided, the SDK uses the stored value.
    public let deviceId: String?
    
    // MARK: - Init
    
    public init(
        displayName: String? = nil,
        usernameType: UsernameType = UsernameType.other,
        txPayload: String? = nil,
        merchantTrustId: String? = nil,
        traceId: String? = nil,
        deviceId: String? = nil
    ) {
        self.displayName = displayName
        self.usernameType = usernameType
        self.txPayload = txPayload
        self.merchantTrustId = merchantTrustId
        self.traceId = traceId
        self.deviceId = deviceId
    }
}
