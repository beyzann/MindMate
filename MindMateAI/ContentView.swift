//
//  MindMateAIApp.swift
//  MindMateAI
//
//  Created by beyzann on 1.04.2026.


import SwiftUI

// MARK: Ana görünüm
struct ContentView: View {
    // @StateObject var langManager = LanguageManager()
    
    @State private var currentStep: AppStep = .login
    @State private var moodHistory: [MoodEntry] = []
    @State private var journalEntries: [JournalEntry] = []
    @State private var positivityEntries: [PositivityEntry] = []
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    /* Dil değiştirme butonu sonraki kontrole kadar devre dışı.
                    HStack {
                        Spacer()
                        Button(langManager.selectedLanguage == .tr ? "🇺🇸 EN" : "🇹🇷 TR") {
                            withAnimation {
                                langManager.selectedLanguage = (langManager.selectedLanguage == .tr ? .en : .tr)
                            }
                        }
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.trailing, 20)
                    }
                    */

                    switch currentStep {
                    case .login:
                        ModernLoginView(currentStep: $currentStep)
                        //  .environmentObject(langManager)
                    case .register:
                        RegisterView(currentStep: $currentStep)
                        //  .environmentObject(langManager)
                    case .registrationSuccess:
                        SuccessRegistrationView(currentStep: $currentStep)
                        //  .environmentObject(langManager)
                    case .moodEntry:
                        MoodSelectionView(moodHistory: $moodHistory, currentStep: $currentStep)
                        //  .environmentObject(langManager)
                    case .mainInterface:
                        MainTabView(moodHistory: $moodHistory, journalEntries: $journalEntries, positivityEntries: $positivityEntries)
                        //  .environmentObject(langManager)
                    }
                }
            }
        }
    }
}

// kayıt ekranı
struct RegisterView: View {
    @Binding var currentStep: AppStep
    // @EnvironmentObject var langManager: LanguageManager
    
    @State private var name = ""; @State private var surname = ""; @State private var email = ""; @State private var password = ""
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        VStack(spacing: 15) {
            Text("Hesap Oluştur").font(.largeTitle.bold()).foregroundColor(.indigo)
            
            Form {
                Section("Kişisel Bilgiler") {
                    TextField("Ad", text: $name)
                    TextField("Soyad", text: $surname)
                }
                Section("Hesap") {
                    TextField("Email", text: $email).textInputAutocapitalization(.none)
                    SecureField("Şifre", text: $password)
                }
            }
            .scrollContentBackground(.hidden)
            
            Button("Kaydı Tamamla") {
                if name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty {
                    alertMsg = "Lütfen tüm alanları doldurun."
                    showAlert = true
                } else if !email.contains("@") {
                    alertMsg = "Geçerli bir e-posta adresi giriniz."
                    showAlert = true
                } else {
                    currentStep = .registrationSuccess
                }
            }
            .frame(maxWidth: .infinity).padding().background(Color.indigo).foregroundColor(.white).cornerRadius(15).bold().padding()
            
            Button("Geri Dön") { currentStep = .login }.foregroundColor(.indigo)
        }
        .alert("Kayıt Hatası", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMsg)
        }
    }
}

struct SuccessRegistrationView: View {
    @Binding var currentStep: AppStep
    // @EnvironmentObject var langManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("Kayıt Başarılı!")
                .font(.largeTitle.bold())
            
            Text("Hesabınız başarıyla oluşturuldu.")
                .foregroundColor(.secondary)
            
            Button("Hadi Başlayalım") {
                currentStep = .moodEntry
            }
            .padding().frame(maxWidth: .infinity).background(Color.indigo).foregroundColor(.white).cornerRadius(15).padding(.horizontal, 40)
        }
    }
}

// MARK: Duygu Seçimi
struct MoodSelectionView: View {
    @Binding var moodHistory: [MoodEntry]
    @Binding var currentStep: AppStep
    let moods = [("Mutlu", "sun.max.fill"), ("Sakin", "leaf.fill"), ("Yorgun", "bed.double.fill"), ("Üzgün", "cloud.rain.fill"), ("Heyecanlı", "bolt.fill"), ("Kaygılı", "waveform.path.ecg")]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Bugün nasıl hissediyorsun?").font(.title.bold())
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(moods, id: \.0) { name, icon in
                    let isSelected = moodHistory.contains(where: { $0.mood == name })
                    VStack {
                        Image(systemName: icon).font(.system(size: 40))
                        Text(name).font(.caption).bold()
                    }
                    .frame(width: 90, height: 90)
                    .background(isSelected ? Color.indigo : Color.white)
                    .foregroundColor(isSelected ? .white : .indigo)
                    .clipShape(Circle()).shadow(radius: 3)
                    .onTapGesture {
                        if isSelected { moodHistory.removeAll(where: { $0.mood == name }) }
                        else if moodHistory.count < 3 { moodHistory.append(MoodEntry(date: Date(), mood: name, icon: icon)) }
                    }
                }
            }.padding()
            if !moodHistory.isEmpty {
                Button("Uygulamaya Başla") { currentStep = .mainInterface }
                    .buttonStyle(.borderedProminent).tint(.indigo)
            }
        }
    }
}

// MARK: Günlük
struct JournalView: View {
    @Binding var entries: [JournalEntry]
    @State private var isAdding = false
    @State private var selectedEntry: JournalEntry? // Düzenlenecek öğeyi tutar

    var body: some View {
        NavigationStack {
            VStack {
                if entries.isEmpty {
                    ContentUnavailableView("Günlük sayfası yok.", systemImage: "book.pages", description: Text("Henüz bir günlük yazmadın."))
                } else {
                    List {
                        // entries.reversed() yerine indekslerle çalışmak düzenleme için daha güvenlidir
                        ForEach(Array(entries.enumerated()).reversed(), id: \.element.id) { index, entry in
                            VStack(alignment: .leading) {
                                Text(entry.title).font(.headline)
                                Text(entry.content).font(.subheadline).lineLimit(2)
                                Text(entry.date.formatted()).font(.caption2).foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEntry = entry // Tıklanan öğeyi seç
                            }
                        }
                        .onDelete { indices in
                            // Ters liste (reversed) olduğu için indeksi doğru hesaplamalıyız
                            for index in indices {
                                let actualIndex = entries.count - 1 - index
                                entries.remove(at: actualIndex)
                            }
                        }
                    }
                }
                Button("Günlük Ekle") { isAdding = true }
                    .padding().frame(maxWidth: .infinity).background(Color.indigo).foregroundColor(.white).cornerRadius(15).padding()
            }
            .navigationTitle("Günlüğüm")
            // Ekleme Sayfası
            .sheet(isPresented: $isAdding) { AddJournalView(entries: $entries, entryToEdit: nil) }
            // Düzenleme Sayfası
            .sheet(item: $selectedEntry) { entry in
                AddJournalView(entries: $entries, entryToEdit: entry)
            }
        }
    }
}

struct AddJournalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var entries: [JournalEntry]
    var entryToEdit: JournalEntry? // Eğer doluysa "Düzenleme" modundayız
    
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Başlık", text: $title)
                TextEditor(text: $content).frame(minHeight: 200)
            }
            .navigationTitle(entryToEdit == nil ? "Yeni Günlük" : "Günlüğü Düzenle")
            .onAppear {
                if let entry = entryToEdit {
                    title = entry.title
                    content = entry.content
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(entryToEdit == nil ? "Ekle" : "Güncelle") {
                        if let entry = entryToEdit, let index = entries.firstIndex(where: { $0.id == entry.id }) {
                            // Mevcut olanı güncelle
                            entries[index] = JournalEntry(date: entry.date, title: title, content: content)
                        } else {
                            // Yeni ekle
                            entries.append(JournalEntry(date: Date(), title: title, content: content))
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
// MARK: Tab içerikleri
struct MainTabView: View {
    @Binding var moodHistory: [MoodEntry]
    @Binding var journalEntries: [JournalEntry]
    @Binding var positivityEntries: [PositivityEntry]
    var body: some View {
        TabView {
            JournalView(entries: $journalEntries).tabItem { Label("Günlük", systemImage: "pencil") }
            AnalyticsView(moodHistory: moodHistory).tabItem { Label("Analiz", systemImage: "chart.bar") }
            ExercisesView(positivityEntries: $positivityEntries).tabItem { Label("Egzersiz", systemImage: "heart") }
            AssistantSelectionView().tabItem { Label("Chat", systemImage: "sparkles") }
        }.tint(.indigo)
    }
}

struct AnalyticsView: View {
    let moodHistory: [MoodEntry]
    var body: some View {
        NavigationStack {
            List(moodHistory.reversed()) { m in
                HStack {
                    Image(systemName: m.icon).foregroundColor(.indigo)
                    Text(m.mood)
                    Spacer()
                    Text(m.date.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                }
            }.navigationTitle("İstatistikler")
        }
    }
}

//Egzersizler
struct ExercisesView: View {
    @Binding var positivityEntries: [PositivityEntry]
    @State private var selectedPositivity: PositivityEntry? // Düzenleme için gerekli

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Nefes Egzersizi") { BreathingView() }
                    // BURAYA DİKKAT: entryToEdit: nil ekledik çünkü yeni kayıt açıyoruz
                    NavigationLink("3 Olumlu Şey") { PositivityView(entries: $positivityEntries, entryToEdit: nil) }
                }

                if !positivityEntries.isEmpty {
                    Section("Kaydedilen Olumlu Anlar") {
                        // Düzenleme ve silme destekli yeni liste yapısı
                        ForEach(Array(positivityEntries.enumerated()).reversed(), id: \.element.id) { index, entry in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundColor(.indigo)
                                Text("• \(entry.thing1)")
                                Text("• \(entry.thing2)")
                                Text("• \(entry.thing3)")
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedPositivity = entry } // Tıklayınca seç
                        }
                        .onDelete { indices in
                            for index in indices {
                                let actualIndex = positivityEntries.count - 1 - index
                                positivityEntries.remove(at: actualIndex)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Egzersizler")
            // Tıklanan öğeyi düzenleme ekranı olarak açar
            .sheet(item: $selectedPositivity) { entry in
                NavigationStack {
                    PositivityView(entries: $positivityEntries, entryToEdit: entry)
                }
            }
        }
    }
}
//Nefes Egzersizi
struct BreathingView: View {
    @State private var scale = 0.5
    @State private var labelText = "Nefes Al"
    
    var body: some View {
        VStack(spacing: 60) {
            Text(labelText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.indigo)
            
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 250, height: 250)
                
                Circle()
                    .fill(Color.indigo.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
            // Metni animasyonla eş zamanlı değiştir
            Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                labelText = (labelText == "Nefes Al" ? "Nefes Ver" : "Nefes Al")
            }
        }
    }
}
//Günlük yazılar
struct PositivityView: View {
    @Binding var entries: [PositivityEntry]
    @Environment(\.dismiss) var dismiss
    var entryToEdit: PositivityEntry? // Bu satır hata almanı engeller
    
    @State private var t1 = ""
    @State private var t2 = ""
    @State private var t3 = ""
    
    var body: some View {
        Form {
            Section("Bugün Seni Mutlu Eden 3 Şey") {
                TextField("Birinci güzel an...", text: $t1)
                TextField("İkinci güzel an...", text: $t2)
                TextField("Üçüncü güzel an...", text: $t3)
            }
            Button(action: {
                if !t1.isEmpty && !t2.isEmpty && !t3.isEmpty {
                    if let entry = entryToEdit, let index = entries.firstIndex(where: { $0.id == entry.id }) {
                        // Mevcut kaydı güncelle
                        entries[index] = PositivityEntry(date: entry.date, thing1: t1, thing2: t2, thing3: t3)
                    } else {
                        // Yeni kayıt ekle
                        entries.append(PositivityEntry(date: Date(), thing1: t1, thing2: t2, thing3: t3))
                    }
                    dismiss()
                }
            }) {
                Text(entryToEdit == nil ? "Güzellikleri Kaydet" : "Güzellikleri Güncelle")
                    .frame(maxWidth: .infinity)
                    .bold()
            }
        }
        .navigationTitle("3 Olumlu Şey")
        .onAppear {
            // Eğer düzenleme modundaysak içini doldur
            if let entry = entryToEdit {
                t1 = entry.thing1
                t2 = entry.thing2
                t3 = entry.thing3
            }
        }
    }
}
//Asistanlar
struct AssistantSelectionView: View {
    let assistants = [
        Assistant(name: "Lucky", imageName: "sparkles", prompt: "Neşeli asistan.", color: .orange),
        Assistant(name: "Charming", imageName: "heart.fill", prompt: "Zarif asistan.", color: .pink)
    ]
    var body: some View {
        NavigationStack {
            List(assistants) { a in
                NavigationLink(destination: ChatView(assistant: a)) {
                    Label(a.name, systemImage: a.imageName).foregroundColor(a.color)
                }
            }.navigationTitle("Asistan Seç")
        }
    }
}

struct ChatView: View {
    let assistant: Assistant
    @State private var text = ""; @State private var msgs: [Message] = []
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(msgs) { m in
                        HStack {
                            if m.isUser { Spacer() }
                            Text(m.content).padding().background(m.isUser ? assistant.color : Color.gray.opacity(0.1)).foregroundColor(m.isUser ? .white : .primary).cornerRadius(10)
                            if !m.isUser { Spacer() }
                        }
                    }.padding(.horizontal)
                }
            }
            HStack {
                TextField("Mesaj...", text: $text).textFieldStyle(.roundedBorder)
                Button("Gönder") { sendMessage() }
            }.padding()
        }.navigationTitle(assistant.name)
    }
    func sendMessage() {
        let input = text; msgs.append(Message(content: input, isUser: true)); text = ""
        Task {
            let res = await AIService.shared.fetchResponse(for: assistant, userMessage: input)
            msgs.append(Message(content: res, isUser: false))
        }
    }
}
