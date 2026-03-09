import SwiftUI

//Word ladder game view
struct ChainPuzzleView: View {
    //Get the crossword entry of this clue
    let entry: PuzzleEntry

    //Get game data
    @EnvironmentObject var viewModel: GameViewModel

    @Environment(\.dismiss) private var dismiss

    //Player input
    @State private var guess = ""

    //stores accepted words
    @State private var chainWords: [String] = []

    //text under submit button
    @State private var feedback = ""

    //if feedback is an error or not
    @State private var showError = false

    //keep keyboard open
    @FocusState private var guessFieldIsFocused: Bool

    //return the most recent accepted word, use starter at start
    private var lastWord: String {
        chainWords.last ?? entry.startWord.uppercased()
    }

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    //Keep the clue at top
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(entry.number). \(entry.clue)")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Start word: \(entry.startWord.uppercased())")
                            .font(.headline)
                            .foregroundStyle(viewModel.theme.accent)
                    }

                    //Show the last accepted word below the clue
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last word")
                            .font(.headline)
                            .foregroundStyle(.white)

                        LetterUnderlineRow(
                            word: lastWord,
                            length: entry.answer.count,
                            textColor: .white,
                            underlineColor: .white
                        )
                    }
                    .padding()
                    .background(viewModel.theme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    //Show current guess input below last accepted word
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your guess")
                            .font(.headline)
                            .foregroundStyle(.white)

                        LetterUnderlineRow(
                            word: guess,
                            length: entry.answer.count,
                            textColor: showError ? .red : .white,
                            underlineColor: showError ? .red : .white
                        )

                        TextField("Enter a word", text: $guess)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .focused($guessFieldIsFocused)
                            //keep letters, make them uppercase, and limit length
                            .onChange(of: guess) { _, newValue in
                                let filtered = newValue
                                    .uppercased()
                                    .filter { $0.isLetter }

                                guess = String(filtered.prefix(entry.answer.count))
                            }
                            .submitLabel(.done)
                            .onSubmit {
                                submitGuess()
                            }

                        Text("Each guess must be a real word and change only one letter from the last word.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding()
                    .background(viewModel.theme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    //Submit button, also uses keyboard enter
                    Button {
                        submitGuess()
                    } label: {
                        Text("Submit Guess")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    //Feedback
                    if !feedback.isEmpty {
                        Text(feedback)
                            .font(.headline)
                            .foregroundStyle(showError ? .red : .green)
                    }

                    //Show full chain so far at bottom
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Chain so far")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(([entry.startWord.uppercased()] + chainWords).joined(separator: " → "))
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(viewModel.theme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    Spacer(minLength: 10)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.never)
        }
        .navigationTitle(entry.direction.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //Delay for keyboard to appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                guessFieldIsFocused = true
            }
        }
    }

    //Check if the inputted word is valid
    private func submitGuess() {
        let cleaned = guess.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        //Check word length
        guard cleaned.count == entry.answer.count else {
            setError("Enter a \(entry.answer.count)-letter word.")
            keepKeyboardOpen()
            return
        }

        //Check the valid word list
        guard viewModel.isWordValid(cleaned) else {
            setError("That word is not in the starter word list.")
            keepKeyboardOpen()
            return
        }

        //Make sure only one letter has changed
        guard viewModel.differsByOneLetter(cleaned, lastWord) else {
            setError("You can only change one letter from \(lastWord).")
            keepKeyboardOpen()
            return
        }

        //if valid at it to the chain
        chainWords.append(cleaned)
        guess = ""
        showError = false
        feedback = "\(cleaned) accepted."

        //Solve the crossword spot when player types in correct answer
        if cleaned == entry.answer.uppercased() {
            feedback = "Correct!"
            guessFieldIsFocused = false
            viewModel.solveEntry(entry.id)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                dismiss()
            }
        } else {
            //keep keyboard open for next guess
            keepKeyboardOpen()
        }
    }

    //helper error message function
    private func setError(_ message: String) {
        feedback = message
        showError = true
    }

    //helper function to keep keyboard focused
    private func keepKeyboardOpen() {
        DispatchQueue.main.async {
            guessFieldIsFocused = true
        }
    }
}

//Draw the underlined letter display
struct LetterUnderlineRow: View {
    let word: String
    let length: Int
    let textColor: Color
    let underlineColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<length, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(character(at: index))
                        .font(.title2.bold())
                        .foregroundStyle(textColor)
                        .frame(width: 24, height: 30)

                    Rectangle()
                        .fill(underlineColor)
                        .frame(width: 24, height: 2)
                }
            }
        }
    }

    //Return one letter from the word or blank if nothing there yet
    private func character(at index: Int) -> String {
        let letters = Array(word.uppercased())

        if index < letters.count {
            return String(letters[index])
        } else {
            return " "
        }
    }
}
