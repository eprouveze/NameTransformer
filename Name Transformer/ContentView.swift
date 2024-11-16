//
//  ContentView.swift
//  Name Transformer
//
//  Created by Emmanuel on 2024/11/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = TransformationStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TransformView(store: store)
                .tabItem {
                    Label("Transform", systemImage: "wand.and.stars")
                }
                .tag(0)
            
            HistoryView(store: store)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
        }
        .tint(.indigo)
    }
}

struct TransformView: View {
    @ObservedObject var store: TransformationStore
    @State private var inputName = ""
    @State private var transformationIndex = 0
    @FocusState private var isInputFocused: Bool
    @State private var isSharing = false
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    @State private var currentTransformation: Transformation?
    
    @State private var typingTimer: Timer?
    private let typingDelay = 0.8
    private let minimumNameLength = 3
    
    private func createTransformation() -> Transformation? {
        guard !inputName.isEmpty else { return nil }
        let transformed = LetterTransformer.transform(inputName, index: transformationIndex)
        return Transformation(original: inputName, transformed: transformed)
    }
    
    private func shouldSaveTransformation(_ name: String) -> Bool {
        // Don't save if too short
        guard name.count >= minimumNameLength else { return false }
        
        // Don't save if it's just a partial word (ends with a space)
        guard !name.hasSuffix(" ") else { return false }
        
        // Don't save if it looks like typing is still in progress
        let words = name.split(separator: " ")
        guard let lastWord = words.last else { return false }
        
        // Additional smart checks:
        
        // Don't save if the last character is a common prefix
        let commonPrefixes = ["Mc", "Mac", "Van", "De", "Le"]
        if commonPrefixes.contains(where: { lastWord.hasSuffix($0) }) {
            return false
        }
        
        // Don't save if it looks like a partial compound name
        if name.hasSuffix("-") {
            return false
        }
        
        // Don't save if the last word is too short (unless it's the only word)
        if words.count > 1 && lastWord.count < 2 {
            return false
        }
        
        // Consider a word "complete" if:
        // - It's at least 2 characters long
        // - Or it's a single letter followed by a period (like initials)
        return lastWord.count >= 2 || (lastWord.count == 1 && name.hasSuffix("."))
    }
    
    var transformedName: String {
        if let current = currentTransformation {
            return current.transformed
        }
        return ""
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.1), .purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text("appTitle")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.indigo)
                            .padding(.bottom, 16)
                        
                        VStack(spacing: 0) {
                            ResultView(
                                title: "Original",
                                text: inputName,
                                textColor: .primary,
                                inputText: $inputName,
                                isEditable: true
                            )
                            .frame(height: geometry.size.height * 0.32)
                            .background(Color.white.opacity(0.8))
                            .onChange(of: inputName) { _, _ in
                                // Cancel existing timer
                                typingTimer?.invalidate()
                                
                                if !inputName.isEmpty {
                                    let newTransformation = createTransformation()
                                    currentTransformation = newTransformation
                                    
                                    // Start new timer
                                    typingTimer = Timer.scheduledTimer(withTimeInterval: typingDelay, repeats: false) { _ in
                                        // Only save if it passes our smart checks
                                        if shouldSaveTransformation(inputName),
                                           let transformation = currentTransformation {
                                            store.addToHistory(transformation)
                                        }
                                    }
                                } else {
                                    currentTransformation = nil
                                }
                            }
                            
                            Divider()
                                .background(.indigo.opacity(0.2))
                            
                            ResultView(
                                title: "Transformed",
                                text: transformedName,
                                textColor: .indigo,
                                transformation: currentTransformation,
                                store: store,
                                inputText: .constant(""),
                                isEditable: false
                            )
                            .frame(height: geometry.size.height * 0.32)
                            .background(Color.white.opacity(0.8))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    transformationIndex += 1
                                    haptics.impactOccurred()
                                    
                                    if let newTransformation = createTransformation() {
                                        currentTransformation = newTransformation
                                        store.addToHistory(newTransformation)
                                    }
                                }
                            } label: {
                                Text("transformAgain")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.indigo, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .opacity(inputName.isEmpty ? 0.5 : 1)
                                    )
                            }
                            .disabled(inputName.isEmpty)
                            
                            Button {
                                isSharing = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.indigo, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .opacity(inputName.isEmpty ? 0.5 : 1)
                                    )
                            }
                            .disabled(inputName.isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(items: [transformedName])
        }
    }
}

struct HistoryView: View {
    @ObservedObject var store: TransformationStore
    @State private var showFavoritesOnly = false
    @State private var showDeleteAllAlert = false
    
    var filteredTransformations: [Transformation] {
        showFavoritesOnly ? store.favorites : store.allHistory
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Toggle(LocalizedStringKey("showFavoritesOnly"), isOn: $showFavoritesOnly)
                    .padding()
                    .tint(.indigo)
                
                List {
                    ForEach(filteredTransformations) { transformation in
                        TransformationRow(transformation: transformation, store: store)
                            .listRowBackground(Color.white.opacity(0.8))
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(
                LinearGradient(
                    colors: [.indigo.opacity(0.1), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle(Text(showFavoritesOnly ? "favorites" : "history"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDeleteAllAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(filteredTransformations.isEmpty)
                }
            }
            .alert(LocalizedStringKey("Delete All"), isPresented: $showDeleteAllAlert) {
                Button(LocalizedStringKey("Cancel"), role: .cancel) { }
                Button(LocalizedStringKey("Delete All"), role: .destructive) {
                    withAnimation {
                        store.removeAllHistory()
                    }
                }
            } message: {
                Text(LocalizedStringKey("Are you sure you want to delete all entries? This cannot be undone."))
            }
        }
    }
}

struct TransformationRow: View {
    let transformation: Transformation
    @ObservedObject var store: TransformationStore
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(transformation.original)
                .font(.headline)
            Text(transformation.transformed)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            HStack {
                Spacer()
                
                // Share button
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [transformation.transformed])
                }
                .padding(.horizontal, 8)
                
                // Favorite button
                Button {
                    withAnimation {
                        store.toggleFavorite(transformation)
                    }
                } label: {
                    Image(systemName: store.isFavorite(transformation) ? "star.fill" : "star")
                        .foregroundColor(store.isFavorite(transformation) ? .yellow : .accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 8)
                
                // Delete button
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
        .alert(LocalizedStringKey("Delete Entry"), isPresented: $showDeleteAlert) {
            Button(LocalizedStringKey("Cancel"), role: .cancel) { }
            Button(LocalizedStringKey("Delete"), role: .destructive) {
                store.removeFromHistory(transformation)
            }
        } message: {
            Text(LocalizedStringKey("Are you sure you want to delete this entry?"))
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ResultView: View {
    let title: String
    let text: String
    let textColor: Color
    var transformation: Transformation?
    var store: TransformationStore?
    @Binding var inputText: String
    let isEditable: Bool
    
    @State private var favoriteToggle = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text(LocalizedStringKey(title))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            
            if isEditable {
                TextField(LocalizedStringKey("typeNamePlaceholder"), text: $inputText)
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
            } else {
                HStack {
                    Spacer()
                    Text(text)
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(textColor)
                        .multilineTextAlignment(.center)
                    
                    if let transformation = transformation,
                       let store = store {
                        Button {
                            store.toggleFavorite(transformation)
                            favoriteToggle.toggle()
                        } label: {
                            Image(systemName: store.isFavorite(transformation) ? "star.fill" : "star")
                                .foregroundStyle(store.isFavorite(transformation) ? .yellow : .gray)
                                .imageScale(.large)
                                .padding(.leading, 8)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .id(favoriteToggle)
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
