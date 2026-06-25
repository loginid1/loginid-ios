//
//  CryptoError.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-11.
//

/// Errors that can occur during cryptographic operations.
enum CryptoError: Error {
    case invalidPublicKeyFormat
    case invalidUTF8Encoding
    case keyNotFound
}
