import Foundation

struct PlanningProgressData: Hashable {
    let title: String
    let subtitle: String
    let statusText: String
    let steps: [PlanningProgressStep]
}

struct PlanningProgressStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let state: StepState
}

enum StepState: Hashable {
    case completed
    case loading
    case pending
}
