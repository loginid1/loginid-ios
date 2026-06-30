//
//  ContentView.swift
//  ExampleAuth
//
//  Created by Michael Braga on 2026-06-28.
//

import SwiftUI
import LoginIDAuth

struct ContentView: View {
    @State private var sdkResult: String = ""
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var passkeyName: String = ""
    @State private var passkeyId: String = ""
    @State private var otp: String = ""
    @State private var txPayload: String = ""
    
    private let lid = LoginIDAuth(baseUrl: "https://AIIICE0385888F3SUK9TL3KO.api.dev.loginid.io")
    
    private func stringify<T>(_ value: T) -> String {
        if value is Void { return "Success" }
        let mirror = Mirror(reflecting: value)
        let children = mirror.children.compactMap { child -> String? in
            guard let label = child.label else { return nil }
            return "\(label): \(child.value)"
        }
        
        if children.isEmpty {
            return String(describing: value)
        }
        
        return children.joined(separator: "\n")
    }
    
    private func invoke<T>(_ action: @escaping () async throws -> T) {
        Task {
            do {
                let result = try await action()
                sdkResult = stringify(result)
            } catch let err as LoginIDError {
                sdkResult = err.msg
            } catch {
                sdkResult = error.localizedDescription
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                Text(sdkResult)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .frame(maxHeight: 150)
            .border(Color.gray, width: 1)
            .padding([.horizontal, .top])
            
            Group {
                TextField("Username", text: $username)
                    .textContentType(.username)
                TextField("Display Name", text: $displayName)
                TextField("Passkey Name", text: $passkeyName)
                TextField("Passkey ID", text: $passkeyId)
                TextField("OTP", text: $otp)
                TextField("TX Payload", text: $txPayload)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            ScrollView {
                VStack(spacing: 8) {
                    Button(action: {
                        invoke {
                            try await lid.createPasskey(username: username)
                        }
                    }) {
                        Text("Create Passkey")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.authenticateWithPasskey(username: username)
                        }
                    }) {
                        Text("Auth with Passkey")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.authenticateWithPasskeyAutofill()
                        }
                    }) {
                        Text("Auth with Passkey (Autofill)")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.confirmTransaction(username: username, txPayload: txPayload)
                        }
                    }) {
                        Text("Confirm Transaction")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.listPasskeys()
                        }
                    }) {
                        Text("List Passkeys")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.renamePasskey(id: passkeyId, name: passkeyName)
                        }
                    }) {
                        Text("Rename Passkey")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.deletePasskey(id: passkeyId)
                        }
                    }) {
                        Text("Delete Passkey")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.requestOtp()
                        }
                    }) {
                        Text("Request OTP")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.validateOtp(username: username, otp: otp)
                        }
                    }) {
                        Text("Validate OTP")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            try await lid.requestAndSendOtp(username: username, method: .email)
                        }
                    }) {
                        Text("Request & Send OTP (email)")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        invoke {
                            lid.getSessionInfo()
                        }
                    }) {
                        Text("Get Session Info")
                            .buttonStyle()
                    }
                    
                    Button(action: {
                        lid.logout()
                        sdkResult = "Logged out"
                    }) {
                        Text("Logout")
                            .buttonStyle()
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

extension Text {
    func buttonStyle() -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
    }
}
