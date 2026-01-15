import Foundation
import Combine
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?
    
    init(locale: Locale = Locale(identifier: "vi-VN")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        
        Task {
            await requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.authorizationStatus = status
                    continuation.resume()
                }
            }
        }
        
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { _ in
                continuation.resume()
            }
        }
    }
    
    var isAuthorized: Bool {
        return authorizationStatus == .authorized
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer không khả dụng"
            return
        }
        
        guard authorizationStatus == .authorized else {
            errorMessage = "Chưa cấp quyền sử dụng microphone"
            return
        }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Không thể khởi tạo audio session"
            return
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.stopRecording()
                }
            }
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            errorMessage = nil
        } catch {
            errorMessage = "Không thể bắt đầu ghi âm"
            stopRecording()
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecording = false
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func reset() {
        stopRecording()
        transcribedText = ""
        errorMessage = nil
    }
}
