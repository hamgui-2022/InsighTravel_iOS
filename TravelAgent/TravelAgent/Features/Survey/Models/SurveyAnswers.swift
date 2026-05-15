import Foundation

struct SurveyAnswers: Hashable {
    var atmosphere: String?
    var budget: String?
    var priority: String?
    var schedule: String?

    var isComplete: Bool {
        atmosphere != nil && budget != nil && priority != nil && schedule != nil
    }

    func value(forKey key: String) -> String? {
        switch key {
        case "atmosphere": return atmosphere
        case "budget":     return budget
        case "priority":   return priority
        case "schedule":   return schedule
        default:           return nil
        }
    }

    mutating func setValue(_ value: String, forKey key: String) {
        switch key {
        case "atmosphere": atmosphere = value
        case "budget":     budget = value
        case "priority":   priority = value
        case "schedule":   schedule = value
        default:           break
        }
    }

    func asDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        if let v = atmosphere { dict["atmosphere"] = v }
        if let v = budget     { dict["budget"]     = v }
        if let v = priority   { dict["priority"]   = v }
        if let v = schedule   { dict["schedule"]   = v }
        return dict
    }
}
