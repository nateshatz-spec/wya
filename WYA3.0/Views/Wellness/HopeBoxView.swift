import SwiftUI
import PhotosUI

struct HopeBoxView: View {
    @EnvironmentObject var store: DataStore
    @State private var selectedItem: PhotosPickerItem?
    @State private var isZenMode = false
    @State private var selectedZenIndex = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.offWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Safe Space")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(Theme.nearBlack)
                            Text("A collection of moments that bring you back to center.")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.midGrey)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        if !store.hopeBoxImages.isEmpty {
                            Button(action: { 
                                isZenMode = true 
                                selectedZenIndex = 0
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("ENTER ZEN MODE")
                                        .font(.system(size: 13, weight: .black))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Theme.blue)
                                .clipShape(Capsule())
                                .shadow(color: Theme.blue.opacity(0.3), radius: 10, y: 5)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            // Add Button
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 28))
                                        .foregroundColor(Theme.blue)
                                    Text("Add Memory")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(Theme.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1.0, contentMode: .fit)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .auraStroke(color: Theme.blue.opacity(0.1))
                            }
                            .onChange(of: selectedItem) { old, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        await MainActor.run {
                                            store.hopeBoxImages.append(data)
                                            store.saveAll()
                                        }
                                    }
                                }
                            }
                            
                            // Existing Images
                            ForEach(store.hopeBoxImages.indices, id: \.self) { index in
                                if let uiImage = UIImage(data: store.hopeBoxImages[index]) {
                                    Button(action: {
                                        selectedZenIndex = index
                                        isZenMode = true
                                    }) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.hopeBoxImages.remove(at: index)
                                            store.saveAll()
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
                
                if isZenMode {
                    zenOverlay
                }
            }
            .navigationBarHidden(isZenMode)
            .toolbar {
                if !isZenMode {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") { dismiss() }
                            .foregroundColor(Theme.midGrey)
                    }
                }
            }
        }
    }
    
    private var zenOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedZenIndex) {
                ForEach(store.hopeBoxImages.indices, id: \.self) { index in
                    if let uiImage = UIImage(data: store.hopeBoxImages[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isZenMode = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(24)
                    }
                }
                Spacer()
                Text("Breathe slowly and focus on why this matters to you.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 1.1)))
        .zIndex(10)
    }
}
