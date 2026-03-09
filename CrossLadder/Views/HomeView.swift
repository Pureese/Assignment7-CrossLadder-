import SwiftUI

//Home screen
struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel

    @State private var showSettings = false
    @State private var showStats = false
    @State private var showAchievements = false

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 10) {
                    Text("CrossLadder")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                NavigationLink(destination: ModeSelectView()) {
                    Text("Play")
                        .font(.title2.bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(viewModel.theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 30)

                Spacer()

                HStack(spacing: 0) {
                    BottomBarButton(title: "Settings", systemImage: "gearshape.fill") {
                        showSettings = true
                    }

                    BottomBarButton(title: "Stats", systemImage: "chart.bar.fill") {
                        showStats = true
                    }

                    BottomBarButton(title: "Achievements", systemImage: "rosette") {
                        showAchievements = true
                    }
                }
                .padding(.vertical, 10)
                .background(viewModel.theme.panel)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showStats) {
            NavigationStack {
                StatsView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showAchievements) {
            NavigationStack {
                AchievementsView()
                    .environmentObject(viewModel)
            }
        }
    }
}

//After tapping play, show the mode selection screen
struct ModeSelectView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDailyMessage = false

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Button {
                    showDailyMessage = true
                } label: {
                    VStack(spacing: 8) {
                        SimpleMenuButtonLabel(
                            title: "Play Daily",
                            color: viewModel.theme.panel
                        )

                        Text("Not implemented yet")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                //tap practice to open difficulties
                NavigationLink(destination: PracticeSelectView()) {
                    SimpleMenuButtonLabel(
                        title: "Practice",
                        color: viewModel.theme.accent
                    )
                }

                NavigationLink(destination: StatsView()) {
                    SimpleMenuButtonLabel(
                        title: "Play History",
                        color: viewModel.theme.panel.opacity(0.85)
                    )
                }

                Spacer()

                Button("Back") {
                    dismiss()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding()
        }
        .navigationTitle("Play")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Daily Mode", isPresented: $showDailyMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("For now, use Practice while we build the rest of the app.")
        }
    }
}

//Lets the player choose the difficulty
struct PracticeSelectView: View {
    @EnvironmentObject var viewModel: GameViewModel

    //When gets a difficulty, go to the crossword for that difficulty
    @State private var selectedDifficulty: PracticeDifficulty?

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Button {
                    startPractice(.easy)
                } label: {
                    SimpleMenuButtonLabel(
                        title: "Easy",
                        color: viewModel.theme.accent
                    )
                }

                Button {
                    startPractice(.medium)
                } label: {
                    SimpleMenuButtonLabel(
                        title: "Medium",
                        color: viewModel.theme.accent
                    )
                }

                Button {
                    startPractice(.hard)
                } label: {
                    SimpleMenuButtonLabel(
                        title: "Hard",
                        color: viewModel.theme.accent
                    )
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedDifficulty) { _ in
            CrosswordView()
        }
    }

    //load the selected puzzle and navigate to crossword screen
    private func startPractice(_ difficulty: PracticeDifficulty) {
        viewModel.loadPracticePuzzle(difficulty)
        selectedDifficulty = difficulty
    }
}

//create the settings screen to simply change the color theme
struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a theme")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            viewModel.theme = theme
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(theme.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text("Change the app colors.")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.75))
                                }

                                Spacer()

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.accent)
                                    .frame(width: 50, height: 50)

                                if viewModel.theme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(viewModel.theme.panel)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

//create the stats screen that displays the completion history
struct StatsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.history) { record in
                        HStack(spacing: 16) {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.theme.accent)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(record.dateText)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.75))

                                Text(record.status.label)
                                    .font(.caption)
                                    .foregroundStyle(record.status.color)
                            }

                            Spacer()

                            Text(record.status.mark)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(record.status.color)
                        }
                        .padding()
                        .background(viewModel.theme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

//Create the achievements screen to show example achievements
struct AchievementsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            viewModel.theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.achievements) { achievement in
                        HStack(spacing: 16) {
                            Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                                .font(.title2)
                                .foregroundStyle(achievement.isUnlocked ? .green : .gray)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(achievement.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(achievement.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Spacer()
                        }
                        .padding()
                        .background(viewModel.theme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

//Make the bottom bar reusable
struct BottomBarButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.headline)

                Text(title)
                    .font(.caption.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

//Make the menu button reusable
struct SimpleMenuButtonLabel: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.title2.bold())
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
