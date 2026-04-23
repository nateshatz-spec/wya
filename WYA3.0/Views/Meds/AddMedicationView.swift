import SwiftUI

struct AddMedicationView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var dose: String = ""
    @State private var time: String = "Morning"
    
    let times = ["Morning", "Afternoon", "Evening", "Bedtime", "As Needed"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g. 20mg)", text: $dose)
                }
                
                Section("Schedule") {
                    Picker("Time of Day", selection: $time) {
                        ForEach(times, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addMedication(name: name, dose: dose, time: time)
                        dismiss()
                    }
                    .disabled(name.isEmpty || dose.isEmpty)
                }
            }
        }
    }
}
