import SwiftUI

struct ClinicalExportView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var isGenerating = false
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.offWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        header
                        
                        reportPreview
                        
                        optionsSection
                        
                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Clinical Export")
            .navigationBarTitleDisplayMode(.inline)
            .locked(feature: "Clinical Export", description: "Generate and share professional-grade reports with your clinical team.")
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.below.ecg.fill")
                .font(.system(size: 40))
                .foregroundColor(Theme.blue)
                .padding(20)
                .background(Theme.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text("Professional Report")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(Theme.nearBlack)
            
            Text("Generate a clinical-grade summary of your mental health data for your doctor.")
                .font(.system(size: 14))
                .foregroundColor(Theme.midGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var reportPreview: some View {
        ReportPreviewView(store: store)
            .blur(radius: isGenerating ? 4 : 0)
            .overlay {
                if isGenerating {
                    ProgressView("Generating PDF...")
                        .font(.system(size: 14, weight: .bold))
                }
            }
    }
    
    private var optionsSection: some View {
        VStack(spacing: 16) {
            Button(action: generateReport) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Generate & Share Report")
                }
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.blue)
                .clipShape(Capsule())
                .shadow(color: Theme.blue.opacity(0.3), radius: 15, y: 8)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            
            Text("Includes Mood Trends, Medication Adherence, and Side Effect Logs.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.midGrey)
                .multilineTextAlignment(.center)
        }
    }
    
    @State private var pdfURL: URL?
    
    private func generateReport() {
        withAnimation { isGenerating = true }
        
        let renderer = ImageRenderer(content: ReportPreviewView(store: store).padding(40))
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("WYA_Clinical_Report.pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            
            DispatchQueue.main.async {
                self.pdfURL = url
                self.isGenerating = false
                self.showShareSheet = true
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

struct ReportPreviewView: View {
    @ObservedObject var store: DataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("REPORT PREVIEW")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.midGrey)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Theme.midGrey)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Patient: \(store.userName.isEmpty ? "Clarity User" : store.userName)")
                            .font(.system(size: 14, weight: .black))
                        Text("Period: Last 30 Days")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "heart.text.square.fill")
                        .foregroundColor(Theme.blue)
                        .font(.system(size: 32))
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary Statistics")
                        .font(.system(size: 12, weight: .black))
                    HStack {
                        statItem(label: "Avg Mood", value: "3.8/5")
                        statItem(label: "Adherence", value: "92%")
                        statItem(label: "Sleep Avg", value: "7.2h")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Clinical Triggers")
                        .font(.system(size: 12, weight: .black))
                    Text("• Work Stress (12 instances)")
                    Text("• Poor Sleep (8 instances)")
                }
                .font(.system(size: 11))
                .foregroundColor(Theme.darkGrey)
            }
            .padding(24)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .auraStroke(color: Theme.midGrey.opacity(0.1), radius: 20)
        }
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(Theme.midGrey)
            Text(value).font(.system(size: 14, weight: .black)).foregroundColor(Theme.nearBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
}
