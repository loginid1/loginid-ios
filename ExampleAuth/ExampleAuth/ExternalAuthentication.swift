//
//  ExternalAuthentication.swift
//  ExampleAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import Foundation

func requestExternalAuthToken(username: String) async throws -> String {
    // TODO: Replace with your API key
    let LOGINID_API_KEY = "YOUR_API_KEY"
    // TODO: Replace with your base URL
    let LOGINID_BASE_URL = "https://<APP_ID>.api.dev.loginid.io"

    // Create the Basic token
    let basicToken = Data("\(LOGINID_API_KEY):".utf8).base64EncodedString()

    // Build the request URL
    guard let url = URL(string: "\(LOGINID_BASE_URL)/fido2/v2/mgmt/grant/external-auth") else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(basicToken)", forHTTPHeaderField: "Authorization")

    // Body
    let body: [String: String] = ["username": username]
    request.httpBody = try JSONEncoder().encode(body)

    // Perform the request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Check status
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }

    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

    if httpResponse.statusCode != 200 {
        let message = json?["message"] as? String ?? json?["msg"] as? String ?? "Unknown error"
        throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
    }

    guard let token = json?["token"] as? String else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found in response"])
    }

    return token
}
