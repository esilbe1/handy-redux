import SwiftUI
import Translation

@main
struct HandyApp: App {
    @StateObject private var container = ServiceContainer.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container)
                .environmentObject(container.recordingViewModel)
                .environmentObject(container.modelManagerViewModel)
                .environmentObject(container.settingsViewModel)
                .environmentObject(container.historyViewModel)
                .environmentObject(container.profilesViewModel)
                .environmentObject(container.dictionaryViewModel)
                .environmentObject(container.snippetsViewModel)
                .environmentObject(container.homeViewModel)
                .environmentObject(container.fileTranscriptionViewModel)
                .environmentObject(container.translationService)
                .environmentObject(container.flowSessionManager)
                .modifier(TranslationTaskModifier(translationService: container.translationService))
                .onOpenURL { url in
                    if url.isFileURL {
                        container.fileTranscriptionViewModel.addFilesFromShare([url])
                        container.flowSessionManager.showFileTranscriptionSheet = true
                        if container.fileTranscriptionViewModel.canTranscribe {
                            container.fileTranscriptionViewModel.transcribeAll()
                        }
                    } else {
                        // If the keyboard opened the app via URL scheme, Full Access is confirmed working.
                        HandyApp.writeFullAccessConfirmation()
                        container.flowSessionManager.handleURL(url)
                    }
                }
                .task {
                    await container.initialize()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        container.flowSessionManager.checkPendingSharedFiles()
                    }
                }
        }
    }
}

extension HandyApp {
    /// Called whenever the main app is opened from the keyboard extension via URL scheme.
    /// Writing `true` to the shared status file is definitive proof that Full Access is working,
    /// since `extensionContext?.open(_:)` only succeeds when the keyboard has Full Access.
    static func writeFullAccessConfirmation() {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: HandyConstants.appGroupIdentifier
        ) else { return }
        let fileURL = groupURL.appending(path: HandyConstants.SharedFiles.keyboardStatusFile)
        let status: [String: Any] = [
            "hasFullAccess": true,
            "confirmedByApp": true,
            "timestamp": Date().timeIntervalSince1970
        ]
        if let data = try? JSONSerialization.data(withJSONObject: status) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}

private struct TranslationTaskModifier: ViewModifier {
    @ObservedObject var translationService: TranslationService

    func body(content: Content) -> some View {
        content
            .translationTask(translationService.configuration) { session in
                await translationService.handleSession(session)
            }
    }
}
