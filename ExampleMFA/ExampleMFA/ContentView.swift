//
//  ContentView.swift
//  ExampleMFA
//
//  Created by Michael Braga on 2025-08-13.
//

import SwiftUI
import LoginIDMFA

struct ContentView: View {
    @State private var sessionResult: MFASessionResult? = nil
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var txPayload: String = ""

    private let lid = LoginIDCheckoutMFA(baseUrl: "")
    
    var body: some View {
        VStack {
            Spacer()
            
            ScrollView {
                Text(sessionResult.map { String(describing: $0) } ?? "No result yet")
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .frame(maxHeight: 200)
            .border(Color.gray, width: 1)
            .padding(.horizontal)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Display Name", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Update TX Payload", text: $txPayload)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button(action: {
                Task {
                    do {
                        let result = try await lid.beginFlow(txPayload: "$100")
                        sessionResult = result
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("Begin")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    do {
                        let token = try await requestExternalAuthToken(username: username)
                        let result = try await lid.performAction(
                            action: .external,
                            options: PerformActionOptions(payload: token)
                        )
                        sessionResult = result
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("External")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    do {
                        let result = try await lid.performAction(
                            action: .passkeyReg, options: PerformActionOptions(displayName: displayName)
                        )
                        sessionResult = result
                        displayName = ""
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("Passkey Create")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    do {
                        let result = try await lid.performAction(
                            action: .passkeyAuth, options: nil
                        )
                        sessionResult = result
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("Passkey Authenticate")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    do {
                        let result = try await lid.performAction(
                            action: .passkeyAuth, options: PerformActionOptions(autoFill: true)
                        )
                        sessionResult = result
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("Passkey Autofill")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }

            Button(action: {
                Task {
                    do {
                        let result = try await lid.performAction(
                            action: .passkeyTx, options: PerformActionOptions( txPayload: txPayload )
                        )
                        sessionResult = result
                        print(result.payloadSignature)
                    } catch let err as LoginIDError {
                        print(err.message)
                    }
                }
            }) {
                Text("Transaction Confirmation")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                TrustID().deleteTrustId()
            }) {
                Text("Delete Trust")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}
