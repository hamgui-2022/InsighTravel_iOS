# ✈️ InsighTravel (iOS)

AI-powered travel assistant app built with **SwiftUI**,  
focused on delivering a seamless **chat → booking experience**.

---

## 📱 Overview

InsighTravel is an iOS application that allows users to:

- Plan trips through natural language chat
- Browse flight and hotel options
- Complete reservations within a unified interface

This project focuses on designing and implementing a **chat-driven UX** that connects directly to real booking flows.

---

## 🎯 My Role (iOS & UI/UX)

- Designed and implemented **SwiftUI-based chat interface**
- Built reusable **card components** for travel content
- Integrated backend APIs into iOS flow
- Translated web-based booking UI into native iOS experience
- Managed state and interaction flow across chat and booking

---

## 🧩 Key Features (iOS)

### 1. Chat-based Interaction

- Natural language input
- Context-aware conversation (session-based)
- Dynamic message rendering

User → Chat Input → API → Response → UI Rendering

---

### 2. Card-driven UI System

The app uses modular card components to display structured data:

- ✈️ Flight recommendation cards
- 🏨 Hotel recommendation cards
- 📋 Booking summary cards
- ⏳ Progress / loading cards

**Key idea:**  
Transform AI responses into **interactive UI components**

---

### 3. Booking Flow Integration

End-to-end flow inside the app:
Chat → Recommendation → Selection → Input → Confirmation
- Item selection (flight / hotel)
- User info input
- Booking request
- Confirmation UI

---

### 4. Web-to-iOS UI Mapping

Existing web booking UIs were analyzed and adapted into SwiftUI:

-  [oai_citation:0‡booking_flight.html](sediment://file_0000000038e872068b4d28c1b91be188)
-  [oai_citation:1‡booking_hotel.html](sediment://file_0000000023ec7206a792d677746ee893)

Converted into:

- Native SwiftUI layouts
- State-driven UI updates
- Component-based architecture

---

## 🏗️ Architecture (iOS Perspective)
[ SwiftUI View Layer ]
↓
[ ViewModel / State ]
↓
[ Network Layer ]
↓
[ FastAPI Backend ]
### Key Points

- Session-based request handling
- Decoupled UI and data logic
- Async API communication

---

## ⚙️ Tech Stack

### iOS
- SwiftUI
- MVVM Architecture
- URLSession (API communication)

### Backend (Integrated)
- FastAPI
- REST API (/chat)

---

## 🔄 Core Flow

### Chat → Booking Experience
1. User sends message
2. API returns structured response
3. UI renders cards
4. User selects item
5. Booking flow begins
6. Confirmation displayed