import SwiftUI

struct MedicalDisclaimerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Label("Important Medical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Theme.red)
                        .padding(.bottom, 10)
                    
                    Text("WYA 3.0 (What's Your Anxiety) is an educational and self-help tool. It is NOT a medical device, nor is it intended to provide professional medical advice, diagnosis, or treatment.")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.nearBlack)
                    
                    Group {
                        Text("**Not Professional Advice:** The clinical exercises, AI-driven insights, and assessments provided in this app (such as CBT, DBT, and PMR guides) are for informational purposes only. They are not a substitute for the judgment of a licensed healthcare provider.")
                        
                        Text("**Emergency Situations:** If you are experiencing a mental health emergency, crisis, or thinking about self-harm, please contact emergency services (911 in the US) or a crisis hotline immediately. Do not rely on this app for emergency support.")
                        
                        Text("**Medication Tracking:** The medication logging feature is a personal record-keeping tool. Always follow the specific instructions provided by your prescribing physician regarding dosage and timing.")
                        
                        Text("**AI Content:** AI-generated wellness articles and insights are based on patterns in your data and general clinical principles. They may contain inaccuracies and should be discussed with a professional before making changes to your treatment plan.")
                    }
                    .font(.system(size: 15))
                    .foregroundColor(Theme.darkGrey)
                    .lineSpacing(4)
                    
                    Text("By using WYA 3.0, you acknowledge that you have read and understood this disclaimer.")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                        .padding(.top, 20)
                }
                .padding(30)
            }
            .navigationTitle("Medical Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("I Understand") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .black))
                }
            }
            .background(Theme.offWhite)
        }
    }
}

#Preview {
    MedicalDisclaimerView()
}
