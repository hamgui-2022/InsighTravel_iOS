import SwiftUI

extension Color {
    static let headerBackground = Color(white: 0.97)
    static let chatBackground = Color(white: 0.95)
    static let outgoingBubble = Color(red: 0.0, green: 0.45, blue: 0.95)
    static let incomingBubble = Color(white: 0.9)
    static let chatText = Color(white: 0.15)
    static let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let imagePlaceholder = Color(white: 0.9)
    static let inputBackground = Color(white: 0.94)
    static let weatherHeader = Color(red: 0.33, green: 0.67, blue: 0.89)
    static let weatherTipBackground = Color(red: 1.0, green: 0.96, blue: 0.86)
    static let weatherTip = Color(red: 0.66, green: 0.46, blue: 0.17)

    // Survey palette (matches chat.html .survey-* classes)
    static let surveyDotActive = Color(red: 0.404, green: 0.678, blue: 0.976)   // #67adf9
    static let surveyDotIdle   = Color(red: 0.816, green: 0.875, blue: 0.961)   // #d0dff5
    static let surveyOptionBorder = Color(red: 0.886, green: 0.910, blue: 0.941) // #e2e8f0
    static let surveyOptionSelectedBG = Color(red: 0.910, green: 0.945, blue: 0.992) // #e8f1fd
    static let surveyOptionSelectedText = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563eb
}
