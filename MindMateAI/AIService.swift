//
//  MindMateAIApp.swift
//  MindMateAI
//
//  Created by beyzann on 1.04.2026.


import Foundation

class AIService {
    static let shared = AIService()
    private let apiKey = "GÜVENLİK SEBEPLİ KİŞİSEL API KEY'İ SİLDİM."

    func fetchResponse(for assistant: Assistant, userMessage: String) async -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return "Bağlantı Hatası" }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Sistem komutu ve kullanıcı mesajı birleştirildi
        let combinedMessage = "Rolün: \(assistant.name). Talimatın: \(assistant.prompt). Kullanıcı diyor ki: \(userMessage)"
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": combinedMessage]
                    ]
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                return "Bağlantı Sorunu (Kod: \(httpResponse.statusCode))"
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return text
            }
        } catch {
            return "Hata: \(error.localizedDescription)"
        }
        return "Cevap alınamadı."
    }
}
