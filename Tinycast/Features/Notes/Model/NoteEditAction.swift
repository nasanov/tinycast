import Foundation

/// A Markdown-aware editing gesture the text view asks `NoteMarkdownEditing` to plan.
enum NoteEditAction: Sendable, Equatable {
    enum InlineStyle: Sendable, CaseIterable { case bold, italic, strikethrough, code }
    enum ListStyle: Sendable { case bullet, ordered, task }

    case newline
    case deleteBackward
    case indent
    case outdent
    case toggleInline(InlineStyle)
    case toggleLink
    /// Level 0 turns the line back into a plain paragraph.
    case setHeading(level: Int)
    case toggleList(ListStyle)
    /// Fences the touched lines, or removes the fences of the block the selection is in.
    case toggleCodeBlock
    case toggleQuote
    case toggleTask(lineIndex: Int)
    /// Turns the touched lines into toggles, or back when every one already is.
    case toggleCollapsible
    /// Flips `>-` and `>+`; nil means the innermost toggle holding the caret.
    case toggleCollapsed(lineIndex: Int?)
    /// The `[] ` input rule.
    case typedSpace
    case pasteURL(String)
}
