import Foundation

enum KeyboardConstants {
    static let appGroupIdentifier = HandyConstants.appGroupIdentifier

    enum SharedFiles {
        static let keyboardHistoryFile = HandyConstants.SharedFiles.keyboardHistoryFile
        static let keyboardProfilesFile = HandyConstants.SharedFiles.keyboardProfilesFile
    }

    enum SharedDefaults {
        static let lastTranscription = HandyConstants.SharedDefaults.lastTranscription
        static let selectedProfileId = HandyConstants.SharedDefaults.selectedProfileId
    }
}
