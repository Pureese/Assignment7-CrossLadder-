import Foundation
import Combine

//Class to store shared game data for whole app, can also be checked for changes
class GameViewModel: ObservableObject {

    //Current theme
    @Published var theme: AppTheme = .ocean

    //Current difficulty
    @Published var selectedDifficulty: PracticeDifficulty = .easy

    //Current puzzle
    @Published var practicePuzzle: WordPuzzle = PracticeDifficulty.easy.puzzle

    @Published var history: [HistoryRecord]

    // Stores the clue solved most recently,crossword and chain puzzle views
    @Published var recentlySolvedEntryID: UUID? = nil

    //List of valid words for puzzles
    private let validWords: Set<String> = [
        // Easy puzzle
        "stop", "step", "stem",
        "flee", "free", "tree",
        "good", "mood", "moon",
        "hero", "zero",

        // Medium puzzle
        "munch", "bunch", "bench", "beach", "peach", "peace", "place",
        "plane", "plans", "clans", "class", "glass", "grass",

        "beast", "boast", "roast", "roust", "rouse", "bouse", "boule",
        "bogle", "bogie", "vogie", "vogue", "rogue",

        "tears", "bears", "beats", "blats", "blate", "slate", "skate",
        "skite", "smite", "smile",

        // Hard puzzle
        "cross", "crass", "brass", "brats", "beans", "beads", "bends",
        "bonds", "bones", "cones", "coves", "cover", "rover", "river",

        "fish", "fist", "fast", "vast", "vase", "vale", "vile", "file",
        "fill", "fell", "feel", "reel"
    ]

    //Runs when the app launches
    init() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let today = formatter.string(from: Date())

        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterday = formatter.string(from: yesterdayDate)

        let twoDaysAgoDate = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let twoDaysAgo = formatter.string(from: twoDaysAgoDate)

        //example history data
        history = [
            HistoryRecord(title: "Practice", dateText: today, status: .notStarted),
            HistoryRecord(title: "Daily Puzzle", dateText: yesterday, status: .started),
            HistoryRecord(title: "Daily Puzzle", dateText: twoDaysAgo, status: .completed)
        ]
    }

    //how many entries are solved
    var solvedCount: Int {
        practicePuzzle.entries.filter { $0.isSolved }.count
    }

    //true when puzzle is complete
    var allSolved: Bool {
        solvedCount == practicePuzzle.entries.count
    }

    //example starter achievements
    var achievements: [Achievement] {
        [
            Achievement(
                title: "First Finish",
                subtitle: "Solve 1 clue",
                isUnlocked: solvedCount >= 1
            ),
            Achievement(
                title: "Getting There",
                subtitle: "Solve 2 clues",
                isUnlocked: solvedCount >= 2
            ),
            Achievement(
                title: "Practice Complete",
                subtitle: "Finish the whole practice puzzle",
                isUnlocked: allSolved
            )
        ]
    }

    //Loads a new puzzle based on difficulty
    func loadPracticePuzzle(_ difficulty: PracticeDifficulty) {
        selectedDifficulty = difficulty
        practicePuzzle = difficulty.puzzle
        recentlySolvedEntryID = nil
        updateTodayHistory()
    }

    //Resets the puzzle
    func resetPracticePuzzle() {
        practicePuzzle = selectedDifficulty.puzzle
        recentlySolvedEntryID = nil
        updateTodayHistory()
    }

    //Returns the clues for a direction
    func entries(for direction: ClueDirection) -> [PuzzleEntry] {
        practicePuzzle.entries
            .filter { $0.direction == direction }
            .sorted { $0.number < $1.number }
    }

    //Mark clue as solved
    func solveEntry(_ entryID: UUID) {
        guard let index = practicePuzzle.entries.firstIndex(where: { $0.id == entryID }) else {
            return
        }

        //Dont open if clue is already solved
        if practicePuzzle.entries[index].isSolved {
            return
        }

        practicePuzzle.entries[index].isSolved = true
        recentlySolvedEntryID = entryID
        updateTodayHistory()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.recentlySolvedEntryID == entryID {
                self.recentlySolvedEntryID = nil
            }
        }
    }

    //Check if word is in starter list
    func isWordValid(_ word: String) -> Bool {
        validWords.contains(word.lowercased())
    }

    //Checks if the word is only one letter different than the last
    func differsByOneLetter(_ first: String, _ second: String) -> Bool {
        let firstUpper = first.uppercased()
        let secondUpper = second.uppercased()

        if firstUpper.count != secondUpper.count {
            return false
        }

        var differenceCount = 0

        for pair in zip(firstUpper, secondUpper) {
            if pair.0 != pair.1 {
                differenceCount += 1
            }
        }

        return differenceCount == 1
    }

    //Get all of the spots that clue covers
    func positions(for entry: PuzzleEntry) -> [(row: Int, col: Int)] {
        var positions: [(row: Int, col: Int)] = []

        for index in 0..<entry.answer.count {
            if entry.direction == .across {
                positions.append((row: entry.row, col: entry.col + index))
            } else {
                positions.append((row: entry.row + index, col: entry.col))
            }
        }

        return positions
    }

    //Check if a cell is part of the crossword
    func isCellActive(row: Int, col: Int) -> Bool {
        for entry in practicePuzzle.entries {
            let entryPositions = positions(for: entry)

            for position in entryPositions {
                if position.row == row && position.col == col {
                    return true
                }
            }
        }

        return false
    }

    //Return the top number of a cell if it starts a clue
    func numberAt(row: Int, col: Int) -> Int? {
        let matchingNumbers = practicePuzzle.entries
            .filter { $0.row == row && $0.col == col }
            .map { $0.number }

        return matchingNumbers.min()
    }

    //Return the letter for the solved cell when the clue is solved
    func letterAt(row: Int, col: Int) -> String? {
        for entry in practicePuzzle.entries {
            if entry.isSolved {
                let entryPositions = positions(for: entry)

                if let index = entryPositions.firstIndex(where: { position in
                    position.row == row && position.col == col
                }) {
                    let letters = Array(entry.answer.uppercased())
                    return String(letters[index])
                }
            }
        }

        return nil
    }

    //Check that the cell belongs to the clue that was just solved
    func isCellInRecentlySolvedEntry(row: Int, col: Int) -> Bool {
        guard let recentID = recentlySolvedEntryID else {
            return false
        }

        guard let recentEntry = practicePuzzle.entries.first(where: { $0.id == recentID }) else {
            return false
        }

        let entryPositions = positions(for: recentEntry)

        for position in entryPositions {
            if position.row == row && position.col == col {
                return true
            }
        }

        return false
    }

    //Replace the first history record when puzzle is completed
    private func updateTodayHistory() {
        guard history.indices.contains(0) else {
            return
        }

        history[0].title = practicePuzzle.title

        if solvedCount == 0 {
            history[0].status = .notStarted
        } else if allSolved {
            history[0].status = .completed
        } else {
            history[0].status = .started
        }
    }
}
