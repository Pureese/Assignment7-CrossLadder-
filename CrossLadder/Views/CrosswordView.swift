import SwiftUI

//Shows the crossword board and clue list
struct CrosswordView: View {
    @EnvironmentObject var viewModel: GameViewModel

    //Correct banner
    @State private var showCorrectBanner = false

    //Store the clue number to scroll to
    @State private var clueNumberToScrollTo: Int? = nil

    //store the clue number to highlight briefly
    @State private var highlightedClueNumber: Int? = nil

    var body: some View {
        ZStack(alignment: .top) {
            viewModel.theme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                progressHeader

                crosswordGrid

                if viewModel.allSolved {
                    Text("Practice puzzle complete!")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.green)
                        .clipShape(Capsule())
                }

                cluePanel

                Spacer(minLength: 0)
            }
            .padding()

            if showCorrectBanner {
                Text("Correct!")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.green)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle(viewModel.practicePuzzle.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset") {
                    viewModel.resetPracticePuzzle()
                }
            }
        }
        .onChange(of: viewModel.recentlySolvedEntryID) { _, newValue in
            if newValue != nil {
                withAnimation {
                    showCorrectBanner = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation {
                        showCorrectBanner = false
                    }
                }
            }
        }
    }

    //Show progress at top of view
    private var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.7))

                Text("\(viewModel.solvedCount) of \(viewModel.practicePuzzle.entries.count) solved")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding()
        .background(viewModel.theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    //Display the crossword grid ,if a numbered square is tapped scroll to it in the clue list
    private var crosswordGrid: some View {
        VStack(spacing: 6) {
            ForEach(0..<viewModel.practicePuzzle.rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<viewModel.practicePuzzle.cols, id: \.self) { col in
                        CrosswordCellView(
                            letter: viewModel.letterAt(row: row, col: col),
                            number: viewModel.numberAt(row: row, col: col),
                            isActive: viewModel.isCellActive(row: row, col: col),
                            isHighlighted: viewModel.isCellInRecentlySolvedEntry(row: row, col: col),
                            theme: viewModel.theme,
                            numberTapAction: {
                                if let number = viewModel.numberAt(row: row, col: col) {
                                    scrollToClue(number)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(viewModel.theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    //Display the scrollable clue pannel at the bottom
    private var cluePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Clues")
                .font(.title3.bold())
                .foregroundStyle(.white)

            //Use ScrollViewReader to scroll to a specific clue row by its id
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        clueSection(
                            title: "Across",
                            entries: viewModel.entries(for: .across)
                        )

                        clueSection(
                            title: "Down",
                            entries: viewModel.entries(for: .down)
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                //when clueNumberToScrollTo changes, scroll there instead
                .onChange(of: clueNumberToScrollTo) { _, newValue in
                    if let number = newValue {
                        withAnimation {
                            proxy.scrollTo(number, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 320, alignment: .top)
        .background(viewModel.theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    //Build the clue section
    private func clueSection(title: String, entries: [PuzzleEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(viewModel.theme.accent)

            ForEach(entries) { entry in
                NavigationLink(destination: ChainPuzzleView(entry: entry)) {
                    clueRow(entry)
                }
                .disabled(entry.isSolved)
                //each row gets its clue number as its id
                .id(entry.number)
            }
        }
    }

    //build the clue row
    private func clueRow(_ entry: PuzzleEntry) -> some View {
        HStack(spacing: 12) {
            Text("\(entry.number)")
                .font(.headline.bold())
                .foregroundStyle(viewModel.theme.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("Start Word")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.7))

                Text(entry.startWord.uppercased())
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }

            Spacer()

            Image(systemName: entry.isSolved ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                .foregroundStyle(entry.isSolved ? .green : .white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            highlightedClueNumber == entry.number
            ? Color.green.opacity(0.25)
            : Color.white.opacity(0.08)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    highlightedClueNumber == entry.number ? Color.green : Color.clear,
                    lineWidth: 2
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    //When a numbered square is tapped
    private func scrollToClue(_ number: Int) {
        clueNumberToScrollTo = number
        highlightedClueNumber = number

        //clear the temporary highlight
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            if highlightedClueNumber == number {
                highlightedClueNumber = nil
            }
        }
    }
}

//Draw one crossword cell
struct CrosswordCellView: View {
    let letter: String?
    let number: Int?
    let isActive: Bool
    let isHighlighted: Bool
    let theme: AppTheme
    let numberTapAction: (() -> Void)?

    var body: some View {
        //if it has a number make it tappable
        if number != nil {
            Button {
                numberTapAction?()
            } label: {
                cellBody
            }
            .buttonStyle(.plain)
        } else {
            cellBody
        }
    }

    //layout of one cell
    private var cellBody: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isHighlighted ? Color.green : Color.clear, lineWidth: 4)
                )

            if isActive, let number {
                Text("\(number)")
                    .font(.caption2.bold())
                    .foregroundStyle(.black.opacity(0.75))
                    .padding(4)
            }

            if let letter {
                Text(letter)
                    .font(.title.bold())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 62, height: 62)
        .scaleEffect(isHighlighted ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHighlighted)
    }

    //Cell background color
    private var backgroundColor: Color {
        if !isActive {
            return theme.background.opacity(0.65)
        }

        if letter == nil {
            return .white
        }

        return theme.accent
    }
}
