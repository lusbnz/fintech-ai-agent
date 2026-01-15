import Foundation
import Combine

class ExportViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var downloadedPDFURL: URL? = nil
    
    func exportStatement() async {
        guard let url = URL(string: "https://qlct.vercel.app/api/v1/transactions/statement/preview") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoded = try JSONDecoder().decode(PDFResponse.self, from: data)
            
            guard let pdfBase64 = decoded.pdf,
                  let pdfData = Data(base64Encoded: pdfBase64) else {
                isLoading = false
                return
            }
            
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("statement.pdf")
            try pdfData.write(to: fileURL)
            
            await MainActor.run {
                self.downloadedPDFURL = fileURL
            }
            
            print("PDF saved to: \(fileURL)")
            
        } catch {
            print("Export error:", error.localizedDescription)
        }
        
        isLoading = false
    }
}
