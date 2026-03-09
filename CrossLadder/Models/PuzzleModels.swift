import SwiftUI

//Says if clue is across or down
enum ClueDirection: String, CaseIterable, Identifiable {
    case across = "Across"
    case down = "Down"

    var id: String { rawValue }
}

//Color themes
enum AppTheme: String, CaseIterable, Identifiable {
    case ocean
    case opal
    case forest

    var id: String { rawValue }

    //Settings screen themes
    var displayName: String {
        switch self {
        case .ocean:
            return "Ocean"
        case .opal:
            return "Opal"
        case .forest:
            return "Forest"
        }
    }

    var background: Color {
        switch self {
        case .ocean:
            return Color(red: 0.08, green: 0.12, blue: 0.22)
        case .opal:
            // Soft pink-purple background.
            return Color(red: 0.43, green: 0.33, blue: 0.38)
        case .forest:
            return Color(red: 0.10, green: 0.18, blue: 0.14)
        }
    }

    var panel: Color {
        switch self {
        case .ocean:
            return Color(red: 0.16, green: 0.22, blue: 0.38)
        case .opal:
            // Rosy panel color.
            return Color(red: 0.62, green: 0.47, blue: 0.54)
        case .forest:
            return Color(red: 0.16, green: 0.28, blue: 0.20)
        }
    }

    var accent: Color {
        switch self {
        case .ocean:
            return Color(red: 0.56, green: 0.84, blue: 0.96)
        case .opal:
            // Almost white with a pink tint.
            return Color(red: 0.98, green: 0.93, blue: 0.96)
        case .forest:
            return Color(red: 0.60, green: 0.86, blue: 0.58)
        }
    }
}

//Practice difficulties
enum PracticeDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }

    //Returns the puzzle for the selected difficulty
    var puzzle: WordPuzzle {
        switch self {
        case .easy:
            return .easyPractice
        case .medium:
            return .mediumPractice
        case .hard:
            return .hardPractice
        }
    }
}

//Stores the crossword answer, clue, and input
struct PuzzleEntry: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let direction: ClueDirection
    let clue: String
    let answer: String
    let startWord: String
    let row: Int
    let col: Int
    var isSolved: Bool = false
}

//Stores the whole puzzle
struct WordPuzzle {
    let title: String
    let rows: Int
    let cols: Int
    var entries: [PuzzleEntry]

    //Easy puzzle build
    static var easyPractice: WordPuzzle {
        WordPuzzle(
            title: "Easy Practice",
            rows: 4,
            cols: 4,
            entries: [
                PuzzleEntry(
                    number: 1,
                    direction: .across,
                    clue: "The middle part of a plant",
                    answer: "STEM",
                    startWord: "STOP",
                    row: 0,
                    col: 0
                ),
                PuzzleEntry(
                    number: 2,
                    direction: .down,
                    clue: "A tall plant with leaves and branches",
                    answer: "TREE",
                    startWord: "FLEE",
                    row: 0,
                    col: 1
                ),
                PuzzleEntry(
                    number: 3,
                    direction: .down,
                    clue: "Earth's natural satellite",
                    answer: "MOON",
                    startWord: "GOOD",
                    row: 0,
                    col: 3
                ),
                PuzzleEntry(
                    number: 4,
                    direction: .across,
                    clue: "Nothing at all",
                    answer: "ZERO",
                    startWord: "HERO",
                    row: 2,
                    col: 0
                )
            ]
        )
    }

    //Medium puzzle build
    static var mediumPractice: WordPuzzle {
        WordPuzzle(
            title: "Medium Practice",
            rows: 5,
            cols: 5,
            entries: [
                PuzzleEntry(
                    number: 1,
                    direction: .across,
                    clue: "It's always greener on the other side",
                    answer: "GRASS",
                    startWord: "MUNCH",
                    row: 0,
                    col: 0
                ),
                PuzzleEntry(
                    number: 2,
                    direction: .down,
                    clue: "To be apart from the heard or group",
                    answer: "ROGUE",
                    startWord: "BEAST",
                    row: 0,
                    col: 1
                ),
                PuzzleEntry(
                    number: 3,
                    direction: .across,
                    clue: "We strive for world _____",
                    answer: "PEACE",
                    startWord: "MUNCH",
                    row: 4,
                    col: 0
                ),
                PuzzleEntry(
                    number: 4,
                    direction: .down,
                    clue: "It uses more muscles to frown, so do this instead",
                    answer: "SMILE",
                    startWord: "TEARS",
                    row: 0,
                    col: 4
                )
            ]
        )
    }

    //Hard puzzle build
    static var hardPractice: WordPuzzle {
        WordPuzzle(
            title: "Hard Practice",
            rows: 5,
            cols: 5,
            entries: [
                PuzzleEntry(
                    number: 1,
                    direction: .across,
                    clue: "A road created by water, for water",
                    answer: "RIVER",
                    startWord: "CROSS",
                    row: 0,
                    col: 0
                ),
                PuzzleEntry(
                    number: 2,
                    direction: .down,
                    clue: "To be fasionable during your time; also a magazine",
                    answer: "VOGUE",
                    startWord: "BEAST",
                    row: 0,
                    col: 2
                ),
                PuzzleEntry(
                    number: 3,
                    direction: .across,
                    clue: "To be apart from the heard or group",
                    answer: "ROGUE",
                    startWord: "BEAST",
                    row: 2,
                    col: 0
                ),
                PuzzleEntry(
                    number: 4,
                    direction: .down,
                    clue: "Rod and ____",
                    answer: "REEL",
                    startWord: "FISH",
                    row: 0,
                    col: 4
                )
            ]
        )
    }
}

//Status for history
enum PuzzleDayStatus {
    case completed
    case started
    case notStarted

    var mark: String {
        switch self {
        case .completed:
            return "✓"
        case .started:
            return "X"
        case .notStarted:
            return "O"
        }
    }

    var color: Color {
        switch self {
        case .completed:
            return .green
        case .started:
            return .orange
        case .notStarted:
            return .gray
        }
    }

    var label: String {
        switch self {
        case .completed:
            return "Completed"
        case .started:
            return "Started"
        case .notStarted:
            return "Not Started"
        }
    }
}

//Example history record for stats screen with unique ID
struct HistoryRecord: Identifiable {
    let id = UUID()

    //Must be a var because it gets updated when user changes it
    var title: String

    let dateText: String

    var status: PuzzleDayStatus
}

//Example achievements for achievement screen
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let isUnlocked: Bool
}
