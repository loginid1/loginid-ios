//
//  LoginIDJWTAccess.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-25.
//

import Foundation

/// Represents the decoded payload of a LoginID access token (JWT).
///
/// This type provides access to the standard JWT claims used by LoginID.
/// The original JWT string is available through the ``jwt`` property after
/// decoding with ``decodeToLoginIdToken(_:)``.
struct LoginIDJWTAccess: Codable {

    /// The authenticated user's username.
    public let username: String

    /// The intended audience of the token.
    public let aud: String

    /// The issuer of the token.
    public let iss: String

    /// The subject identifier for the authenticated user.
    public let sub: String

    /// The token expiration time, expressed as seconds since the Unix epoch.
    public let exp: Int64

    /// The original encoded JWT.
    ///
    /// This value is not part of the JWT payload. It is populated after a
    /// successful call to ``decodeToLoginIdToken(_:)``.
    public var jwt: String?

    /// Decodes a LoginID JWT into a ``LoginIDJWTAccess`` instance.
    ///
    /// The JWT payload is Base64URL-decoded and deserialized into a
    /// ``LoginIDJWTAccess``. If decoding succeeds, the original JWT string is
    /// stored in the returned instance's ``jwt`` property.
    ///
    /// - Parameter jwt: The encoded JWT string.
    /// - Returns: A decoded ``LoginIDJWTAccess`` instance, or `nil` if the JWT
    ///   is malformed or its payload cannot be decoded.
    static func decodeToLoginIdToken(_ jwt: String) -> Self? {
        let segments = jwt.split(separator: ".")

        guard segments.count == 3,
              let payloadData = String(segments[1]).base64URLDecode(),
              var token = try? JSONDecoder().decode(Self.self, from: payloadData)
        else {
            return nil
        }

        token.jwt = jwt
        return token
    }
}
