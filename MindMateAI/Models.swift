import SwiftUI
import Combine

enum AppStep {
    case login, register, registrationSuccess, moodEntry, mainInterface
}

// MARK: - VERİ MODELLERİ
struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let mood: String
    let icon: String
}

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let title: String
    let content: String
}

struct PositivityEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let thing1: String
    let thing2: String
    let thing3: String
}

struct Assistant: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let prompt: String
    let color: Color
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

// MARK: - Dil yöneticisi denemesi. Ek entegrede sorun yaşadığım için şu anlık yorum satırına aldım.
/*
enum Language: String {
    case tr, en
}

class LanguageManager: ObservableObject {
    @Published var selectedLanguage: Language = .tr
    
    func t(_ key: String) -> String {
        let translations: [String: [Language: String]] = [
            "back": [.tr: "Geri Dön", .en: "Go Back"],
            "save": [.tr: "Kaydet", .en: "Save"],
            "update": [.tr: "Güncelle", .en: "Update"],
            "add": [.tr: "Ekle", .en: "Add"],
            "email": [.tr: "E-posta", .en: "Email"],
            "password": [.tr: "Şifre", .en: "Password"],
            "login_btn": [.tr: "Giriş Yap", .en: "Login"],
            "create_account": [.tr: "Hesap Oluştur", .en: "Create Account"],
            "first_name": [.tr: "Ad", .en: "First Name"],
            "last_name": [.tr: "Soyad", .en: "Last Name"],
            "personal_info": [.tr: "Kişisel Bilgiler", .en: "Personal Info"],
            "account": [.tr: "Hesap", .en: "Account"],
            "register_complete": [.tr: "Kaydı Tamamla", .en: "Complete Registration"],
            "success": [.tr: "Kayıt Başarılı!", .en: "Registration Success!"],
            "start": [.tr: "Hadi Başlayalım", .en: "Let's Get Started"],
            "journal": [.tr: "Günlük", .en: "Journal"],
            "stats": [.tr: "Analiz", .en: "Analytics"],
            "exercises": [.tr: "Egzersiz", .en: "Exercises"],
            "chat": [.tr: "Chat", .en: "Chat"],
            "how_feel": [.tr: "Bugün nasıl hissediyorsun?", .en: "How are you feeling today?"],
            "start_app": [.tr: "Uygulamaya Başla", .en: "Start App"]
        ]
        return translations[key]?[selectedLanguage] ?? key
    }
}
*/
