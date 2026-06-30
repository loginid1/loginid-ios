//
//  AuthInit+MergeFallback.swift
//  LoginIDCore
//
//  Created by Michael Braga on 2026-06-26.
//

public extension AuthInit {
    func mergeFallbackMethods() -> [String] {
        let a = crossAuthMethods.map { $0.rawValue }
        let b = fallbackMethods.map { $0.rawValue }
        return a + b
    }
}
