//
//  MindMateAIApp.swift
//  MindMateAI
//
//  Created by beyzann on 7.04.2026.

import SwiftUI

struct ModernLoginView: View {
    @Binding var currentStep: AppStep
    @State private var email = ""
    @State private var password = ""
    @State private var isAnimate = false
    
    // Yeni eklenen state'ler
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Arka Plan
            LinearGradient(colors: [Color.indigo.opacity(0.15), Color.mint.opacity(0.1), .white],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()
                
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "brain.headspins")
                        .font(.system(size: 75))
                        .foregroundStyle(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .indigo.opacity(0.3), radius: 15, x: 0, y: 10)
                        .offset(y: isAnimate ? -8 : 8)
                    
                    Text("MindMate")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.indigo.opacity(0.8))
                }
                .padding(.bottom, 20)

                // Giriş Kartı
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        CustomInputField(icon: "envelope.fill", placeholder: "E-posta", text: $email)
                        CustomInputField(icon: "lock.fill", placeholder: "Şifre", text: $password, isSecure: true)
                    }

                    Button(action: {
                        validateLogin()
                    }) {
                        Text("Giriş Yap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.indigo, .indigo.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(16)
                            .shadow(color: .indigo.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    Button(action: { currentStep = .register }) {
                        Text("Yeni bir hesap oluştur")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(30)
                .background(.white.opacity(0.5))
                .background(BlurEffect(style: .systemThinMaterialLight))
                .cornerRadius(32)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.5), lineWidth: 1))
                .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 25)
                .offset(y: isAnimate ? -4 : 4)

                Spacer()
            }
        }
        .alert("Hata", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimate = true
            }
        }
    }


    private func validateLogin() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Lütfen tüm alanları doldurun."
            showAlert = true
        } else if !email.contains("@") || !email.contains(".") {
            errorMessage = "Geçerli bir e-posta adresi giriniz."
            showAlert = true
        } else {
            currentStep = .moodEntry
        }
    }
}

struct CustomInputField: View {
    let icon: String; let placeholder: String; @Binding var text: String; var isSecure: Bool = false
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.indigo.opacity(0.4)).frame(width: 25)
            if isSecure { SecureField(placeholder, text: $text) }
            else { TextField(placeholder, text: $text).textInputAutocapitalization(.none) }
        }
        .padding().background(Color.white.opacity(0.7)).cornerRadius(12)
    }
}

struct BlurEffect: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: style)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
