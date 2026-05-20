# ✈️ InsighTravel (iOS)

AI-powered travel assistant built with **SwiftUI**,
focused on a seamless **chat → planning → booking** experience.

> Xcode 프로젝트명: `TravelAgent` · 앱 표시명: **InsighTravel**

---

## 📱 Overview

InsighTravel is an iOS application that lets users:

- Plan trips through natural-language chat
- Receive structured itinerary, weather, and transport suggestions as cards
- Browse and reserve flights and hotels inside the chat flow
- Review past bookings and cancel from a dedicated history screen

This project focuses on translating an AI agent's text replies into an
**interactive, card-based iOS UX** that drives real booking flows.

---

## 🎯 My Role (iOS & UI/UX)

- Designed and implemented the **SwiftUI chat interface** end-to-end
- Built a **modular card system** for travel content (trip goal, planner,
  itinerary, hotel/flight search, booking confirmation, survey, error)
- Implemented **multi-session chat** with sidebar, persistence, and restore
- Built the full **booking flow** (selection → form → review → confirmation)
  and the **booking history** screen
- Integrated the FastAPI backend via `URLSession` with async/await
- Branded the app: mascot app icon, splash screen, mascot watermark,
  display name override

  ---

## 🧩 Key Features

### 1. Chat-based Interaction
- Natural-language input with session-aware context
- Multi-session support with a slide-in **history sidebar**
- Per-session chat items persisted across app launches (`UserDefaults`)
- Loading / error states rendered inline as dedicated cards

### 2. Pre-Trip Survey
- Lightweight in-chat survey card collecting trip preferences
- Active / completed card states with SF Symbol-based options
- Answers are attached to subsequent chat requests as `survey` payload

### 3. Card-driven UI System
The agent's reply is mapped to typed `ChatItem` cases, each rendered as a card:

- 🎯 **Trip Goal** — destination, duration, style, notes
- 🧭 **Planner Summary** — trip stage + step list with tool tags
- 🌤 **Itinerary** — structured weather (periods, outfit tip), time-slots
  (morning / noon / afternoon / evening / night), transport (transit & taxi),
  and event list
- 🏨 **Hotel Search** CTA card → opens hotel selection sheet
- ✈️ **Flight Search** CTA card → opens flight selection sheet
- ✅ **Booking Confirmation** cards (hotel / flight)
- ⚠️ **Error** card for failed requests

### 4. Booking Flow
End-to-end inside the app:
Chat → Search CTA → Selection Sheet → Form (passenger/guest info)
→ Review → Confirm → Completion screen → Confirmation card in chat

- Hotel and flight have parallel flows with shared form components
- Selected item index and form input are sent to the backend
  (`item_index`, `booking_type`, `passenger_info`)
- Completion screen + chat-side confirmation card on success

### 5. Booking History
- Dedicated screen listing past bookings for the current session
- Detail view with the original booking payload
- Cancel action wired to backend

### 6. Branding
- Custom mascot **app icon** and **splash screen**
- Mascot **watermark** in the chat background
- App display name set to **InsighTravel**

---

## 🏗️ Architecture

Feature-based modular layout, MVVM on the SwiftUI side:

```
TravelAgent/
├─ App/                  # Entry point, splash, root container
├─ Core/Extensions/      # Color theme & shared extensions
└─ Features/
   ├─ Chat/
   │  ├─ Models/         # ChatItem, ChatSession, card data, planner payloads
   │  ├─ ViewModels/     # ChatViewModel (sessions, items, booking state, survey)
   │  ├─ Views/          # ChatView, sidebar, header, input bar, message bubble
   │  │  └─ Cards/       # Itinerary / Planner / Trip goal / Hotel / Flight / …
   │  └─ Services/       # ChatAPIService, ChatResponseMapper
   ├─ Booking/
   │  ├─ Models/         # BookingFlowState, form data, history item
   │  ├─ ViewModels/     # BookingHistoryViewModel
   │  ├─ Views/          # Selection sheets, forms, review, completion, history
   │  └─ Services/       # BookingAPIService, BookingHistoryAPIService
   └─ Survey/
      ├─ Models/         # SurveyQuestion, SurveyAnswers
      ├─ Views/          # Active / Completed survey card
      └─ Services/       # SurveyAPIService
```

### Flow
```
[ SwiftUI View ] ↔ [ @ObservableObject ViewModel ]
                            ↓
                  [ Service (URLSession) ]
                            ↓
                  [ FastAPI Backend /chat, /booking, ... ]
```

### Key Points
- `ChatViewModel` is the single source of truth for chat items, sessions,
  cached booking items, survey state, and booking flow state
- `ChatResponseMapper` converts the backend `ChatResponse` (reply, plan,
  trip_goal, hotel_items, flight_items) into typed `ChatItem` cases
- Per-session state is keyed by `session_id` and persisted in `UserDefaults`
- Async/await everywhere on the network layer

---

## ⚙️ Tech Stack

### iOS
- **SwiftUI** (iOS 17+ target)
- **MVVM** with `@Published` state on `ObservableObject` view models
- **async/await + URLSession** for networking
- **UserDefaults** for session/chat persistence
- **SF Symbols** for iconography

### Backend (integrated, separate repo)
- **FastAPI**
- REST endpoints: `/chat`, booking & history endpoints
- Default dev endpoint: `http://127.0.0.1:8000`

---

## 🔄 Core Flow
1. User sends a message (+ optional survey answers)
2. /chat returns reply + plan + trip_goal + hotel_items / flight_items
3. ChatResponseMapper turns the payload into typed cards
4. User taps a search CTA → selection sheet → form → review → confirm
5. Booking is posted; confirmation card appears in chat
6. Booking history screen lets the user revisit or cancel


---

## 🚀 Getting Started

1. Open `TravelAgent/TravelAgent.xcodeproj` in Xcode
2. Run the FastAPI backend locally (default `http://127.0.0.1:8000`)
3. Build & run on an iOS 17+ simulator or device
4. (Optional) Change the endpoint in
   `Features/Chat/Services/ChatAPIService.swift`
