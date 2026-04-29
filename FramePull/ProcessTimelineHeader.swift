import SwiftUI

/// The three phases of the post-marking workflow.
enum ProcessPhase: Int, CaseIterable, Identifiable {
    case review = 0
    case grid = 1
    case export = 2

    var id: Int { rawValue }
    var index: Int { rawValue + 1 }

    var title: String {
        switch self {
        case .review: return "Review & Select"
        case .grid:   return "Create Grids"
        case .export: return "Export"
        }
    }

    var icon: String {
        switch self {
        case .review: return "checklist"
        case .grid:   return "square.grid.2x2"
        case .export: return "square.and.arrow.up"
        }
    }
}

/// Visual horizontal timeline showing the three phases.
/// Pills are freely clickable in any direction — users can revisit earlier phases.
/// Visited pills show a checkmark; the active pill is highlighted; unvisited pills are subtle.
struct ProcessTimelineHeader: View {
    /// `nil` means the user has not entered any phase yet.
    let activePhase: ProcessPhase?
    /// Phases the user has been on (including past visits). Used for the checkmark visual.
    let visitedPhases: Set<ProcessPhase>
    /// Called when the user taps a pill.
    let onTap: (ProcessPhase) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProcessPhase.allCases) { phase in
                pill(for: phase)
                if phase != .export {
                    connector(after: phase)
                }
            }
        }
    }

    private func pill(for phase: ProcessPhase) -> some View {
        let state = pillState(for: phase)
        return Button {
            onTap(phase)
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(state.circleFill)
                        .frame(width: 22, height: 22)
                    if state == .visited {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(phase.index)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(state.numberColor)
                    }
                }
                Text(phase.title)
                    .font(.system(size: 13, weight: state == .active ? .semibold : .regular))
                    .foregroundColor(state.textColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(state.backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(state.borderColor, lineWidth: state == .active ? 1.5 : 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .help(helpText(for: phase, state: state))
    }

    private func connector(after phase: ProcessPhase) -> some View {
        Rectangle()
            .fill(connectorFill(after: phase))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
    }

    // MARK: - State helpers

    fileprivate enum PillState { case unvisited, active, visited }

    fileprivate func pillState(for phase: ProcessPhase) -> PillState {
        if phase == activePhase { return .active }
        if visitedPhases.contains(phase) { return .visited }
        return .unvisited
    }

    private func connectorFill(after phase: ProcessPhase) -> Color {
        guard let next = ProcessPhase(rawValue: phase.rawValue + 1) else { return .secondary.opacity(0.2) }
        let leftDone  = visitedPhases.contains(phase) || activePhase == phase
        let rightDone = visitedPhases.contains(next) || activePhase == next
        if leftDone && rightDone { return .framePullBlue.opacity(0.6) }
        if leftDone || rightDone { return .framePullBlue.opacity(0.35) }
        return .secondary.opacity(0.2)
    }

    private func helpText(for phase: ProcessPhase, state: PillState) -> String {
        switch state {
        case .active:    return "Current step"
        case .visited:   return "Go back to \(phase.title)"
        case .unvisited: return "Jump to \(phase.title)"
        }
    }
}

private extension ProcessTimelineHeader.PillState {
    var circleFill: Color {
        switch self {
        case .active:    return .framePullBlue
        case .visited:   return .framePullBlue.opacity(0.85)
        case .unvisited: return .secondary.opacity(0.2)
        }
    }
    var numberColor: Color {
        switch self {
        case .active:    return .white
        case .visited:   return .white
        case .unvisited: return .secondary
        }
    }
    var textColor: Color {
        switch self {
        case .active:    return .primary
        case .visited:   return .primary
        case .unvisited: return .secondary
        }
    }
    var backgroundFill: Color {
        switch self {
        case .active:    return Color.framePullBlue.opacity(0.10)
        case .visited:   return .clear
        case .unvisited: return .clear
        }
    }
    var borderColor: Color {
        switch self {
        case .active: return .framePullBlue.opacity(0.6)
        default:      return .clear
        }
    }
}
