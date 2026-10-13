import Foundation

/// Pins in pin order, first five on ⌘1…⌘5, by filename, so a rename carries one and Trash drops it.
struct NotePins: RawRepresentable, Equatable, Sendable {
    static let shortcuts = 1...5

    private(set) var ids: [NoteID] = []

    init() {}

    init(rawValue: [String]) {
        for name in rawValue where !name.isEmpty {
            let id = NoteID(rawValue: name)
            if !ids.contains(id) { ids.append(id) }
        }
    }

    var rawValue: [String] { ids.map(\.rawValue) }

    func contains(_ id: NoteID) -> Bool {
        ids.contains(id)
    }

    func shortcut(of id: NoteID) -> Int? {
        guard let index = ids.firstIndex(of: id), Self.shortcuts.contains(index + 1) else { return nil }
        return index + 1
    }

    func note(atShortcut number: Int) -> NoteID? {
        Self.shortcuts.contains(number) && number <= ids.count ? ids[number - 1] : nil
    }

    /// Pinning appends, so an earlier pin keeps its shortcut.
    mutating func toggle(_ id: NoteID) {
        if let index = ids.firstIndex(of: id) {
            ids.remove(at: index)
        } else {
            ids.append(id)
        }
    }

    mutating func rename(_ id: NoteID, to renamed: NoteID) {
        ids = ids.map { $0 == id ? renamed : $0 }
    }

    /// The listing is the folder's truth, so a note gone from it, by any route, loses its pin.
    mutating func retain(_ existing: some Sequence<NoteID>) {
        let existing = Set(existing)
        ids.removeAll { !existing.contains($0) }
    }

    /// Pinned notes first, in pin order, then the rest in their given order.
    func ordering(_ summaries: [NoteSummary]) -> [NoteSummary] {
        let byID = Dictionary(summaries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return ids.compactMap { byID[$0] } + summaries.filter { !contains($0.id) }
    }
}
