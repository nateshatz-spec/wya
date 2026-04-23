import SwiftUI

struct SafetyPlanEditorView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var plan: SafetyPlan = .empty
    
    @State private var newWarningSign = ""
    @State private var newCopingStrategy = ""
    @State private var newSafeContact = ""
    @State private var newProfessionalContact = ""
    @State private var newEnvironmentStep = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("A safety plan is a set of instructions that you create for yourself to help you through a crisis.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.midGrey)
                        .listRowBackground(Color.clear)
                }
                
                // MARK: - Warning Signs
                Section {
                    List {
                        ForEach(plan.warningSigns, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { plan.warningSigns.remove(atOffsets: $0) }
                        
                        HStack {
                            TextField("e.g. Can't sleep, Feeling stuck", text: $newWarningSign)
                            Button(action: {
                                guard !newWarningSign.isEmpty else { return }
                                plan.warningSigns.append(newWarningSign)
                                newWarningSign = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.blue)
                            }
                        }
                    }
                } header: {
                    Label("Warning Signs", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11, weight: .black))
                } footer: {
                    Text("Thoughts, moods, or behaviors that tell you a crisis might be starting.")
                }
                
                // MARK: - Coping Strategies
                Section {
                    List {
                        ForEach(plan.copingStrategies, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { plan.copingStrategies.remove(atOffsets: $0) }
                        
                        HStack {
                            TextField("e.g. Taking a walk, 5-4-3-2-1 grounding", text: $newCopingStrategy)
                            Button(action: {
                                guard !newCopingStrategy.isEmpty else { return }
                                plan.copingStrategies.append(newCopingStrategy)
                                newCopingStrategy = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.blue)
                            }
                        }
                    }
                } header: {
                    Label("Coping Strategies", systemImage: "bolt.fill")
                        .font(.system(size: 11, weight: .black))
                } footer: {
                    Text("Things you can do on your own to take your mind off your problems.")
                }
                
                // MARK: - Safe Contacts
                Section {
                    List {
                        ForEach(plan.safeContacts, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { plan.safeContacts.remove(atOffsets: $0) }
                        
                        HStack {
                            TextField("Name and phone number", text: $newSafeContact)
                            Button(action: {
                                guard !newSafeContact.isEmpty else { return }
                                plan.safeContacts.append(newSafeContact)
                                newSafeContact = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.blue)
                            }
                        }
                    }
                } header: {
                    Label("People who can help", systemImage: "person.2.fill")
                        .font(.system(size: 11, weight: .black))
                } footer: {
                    Text("Friends or family members you can call for support.")
                }
                
                // MARK: - Professional Contacts
                Section {
                    List {
                        ForEach(plan.professionalContacts, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { plan.professionalContacts.remove(atOffsets: $0) }
                        
                        HStack {
                            TextField("Doctor, Therapist, or Clinic", text: $newProfessionalContact)
                            Button(action: {
                                guard !newProfessionalContact.isEmpty else { return }
                                plan.professionalContacts.append(newProfessionalContact)
                                newProfessionalContact = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.blue)
                            }
                        }
                    }
                } header: {
                    Label("Professional Support", systemImage: "staroflife.fill")
                        .font(.system(size: 11, weight: .black))
                } footer: {
                    Text("Names and numbers of professionals or agencies.")
                }
                
                // MARK: - Safe Environment
                Section {
                    List {
                        ForEach(plan.safeEnvironmentSteps, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { plan.safeEnvironmentSteps.remove(atOffsets: $0) }
                        
                        HStack {
                            TextField("e.g. Removing pills, giving car keys to a friend", text: $newEnvironmentStep)
                            Button(action: {
                                guard !newEnvironmentStep.isEmpty else { return }
                                plan.safeEnvironmentSteps.append(newEnvironmentStep)
                                newEnvironmentStep = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.blue)
                            }
                        }
                    }
                } header: {
                    Label("Making the environment safe", systemImage: "shield.fill")
                        .font(.system(size: 11, weight: .black))
                } footer: {
                    Text("Steps you can take to remove access to things you could use to hurt yourself.")
                }
            }
            .navigationTitle("Your Safety Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: 20) {
                        Button {
                            exportToPDF()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button("Save") {
                            store.updateSafetyPlan(plan)
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .onAppear {
                self.plan = store.safetyPlan
            }
        }
    }
    
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    
    private func exportToPDF() {
        let renderer = ImageRenderer(content: SafetyPlanPDFView(plan: plan).padding(40))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("WYA_Safety_Plan.pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            
            DispatchQueue.main.async {
                self.pdfURL = url
                self.showShareSheet = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

struct SafetyPlanPDFView: View {
    let plan: SafetyPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MY SAFETY PLAN")
                        .font(.system(size: 28, weight: .black))
                    Text("Generated on \(Date().formatted(date: .long, time: .shortened))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "shield.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            pdfSection(title: "Warning Signs", items: plan.warningSigns, icon: "exclamationmark.triangle")
            pdfSection(title: "Coping Strategies", items: plan.copingStrategies, icon: "bolt")
            pdfSection(title: "People Who Can Help", items: plan.safeContacts, icon: "person.2")
            pdfSection(title: "Professional Support", items: plan.professionalContacts, icon: "staroflife")
            pdfSection(title: "Environment Safety", items: plan.safeEnvironmentSteps, icon: "shield")
            
            Spacer()
            
            Text("In an emergency, call 911 or your local crisis line.")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 500)
    }
    
    private func pdfSection(title: String, items: [String], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .bold))
            
            if items.isEmpty {
                Text("None listed")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                        .font(.system(size: 14))
                }
            }
        }
    }
}
