import Foundation

/// Decides which lines a collapsed toggle hides from layout; the source keeps every one of them.
enum NoteFoldPolicy {
    /// Collapsed bodies, except one the selection starts or ends in, so Find and the caret can see.
    static func foldedLines(selection: NSRange, markdown: NoteMarkdown) -> IndexSet {
        var folded = IndexSet()
        for toggle in markdown.toggles {
            guard case .toggle(collapsed: true) = markdown.lines[toggle.line].kind, let body = toggle.body,
                !holds(selection, body: body, in: markdown)
            else { continue }
            folded.insert(integersIn: body.lowerBound..<(body.upperBound + 1))
        }
        return folded
    }

    /// True when the caret, or either end of a selection, lies inside the body's text.
    static func holds(_ selection: NSRange, body: ClosedRange<Int>, in markdown: NoteMarkdown) -> Bool {
        guard selection.location != NSNotFound else { return false }
        let start = markdown.lines[body.lowerBound].range.location
        let end = NSMaxRange(markdown.lines[body.upperBound].contentRange)
        return [selection.location, NSMaxRange(selection)].contains { start <= $0 && $0 <= end }
    }

    /// The innermost toggle whose line or body holds the caret.
    static func enclosingToggle(of selection: NSRange, in markdown: NoteMarkdown) -> NoteMarkdown.Toggle? {
        guard selection.location != NSNotFound, let line = markdown.lineIndex(at: selection.location)
        else { return nil }
        return markdown.toggles.last { toggle in
            toggle.line == line || toggle.body?.contains(line) == true
        }
    }

    /// Carries a folded set across an edit; the edited lines are restyled anyway, so they drop out.
    static func shifted(
        _ folded: IndexSet, editedOldLines: Range<Int>, editedNewLines: Range<Int>
    ) -> IndexSet {
        let delta = editedNewLines.count - editedOldLines.count
        var shifted = IndexSet()
        for index in folded where !editedOldLines.contains(index) {
            shifted.insert(index < editedOldLines.lowerBound ? index : index + delta)
        }
        return shifted
    }
}
