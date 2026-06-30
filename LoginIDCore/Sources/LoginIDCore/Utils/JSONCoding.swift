//
//  JSONCoding.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2025-08-12.
//

import Foundation

/// A utility for creating preconfigured JSON encoders and decoders
/// with consistent formatting and key strategies across the app.
final public class JSONCoding {
    /**
     Creates a `JSONEncoder` instance with predefined settings:
       - `.withoutEscapingSlashes` for cleaner JSON output.
       - `.useDefaultKeys` to preserve Swift property names (camelCase) as JSON keys.
     
     - Returns: A configured `JSONEncoder` ready for use.
     */
    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        // Keep Swift naming (camelCase) to match property names.
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }

    /**
     Creates a `JSONDecoder` instance with a predefined setting:
       - `.useDefaultKeys` to match JSON keys directly to Swift property names (camelCase).
     
     - Returns: A configured `JSONDecoder` ready for use.
     */
    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
}
