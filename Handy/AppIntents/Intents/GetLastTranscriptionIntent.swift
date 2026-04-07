import AppIntents

struct GetLastTranscriptionIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Last Transcription"
    static let description = IntentDescription("Return the latest transcription stored in Handy history.")
    static let openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let payload = try await HandyIntentFacade.shared.getLastTranscription()
        return .result(
            value: payload.jsonString,
            dialog: IntentDialog("Loaded latest transcription.")
        )
    }
}
