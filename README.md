# Transfers 🏦

A modern iOS banking application demonstrating best practices and industry-standard architecture patterns. This sample project showcases a complete transfer management system with full CRUD operations, built using Apple's latest technologies and frameworks.

![Demo](https://github.com/kebuenokebueno/transfers/blob/main/demo.gif)

## 📱 Overview

Transfers is a banking app that allows users to manage money transfers with a focus on:
- **Clean Architecture** - Maintainable and testable codebase using MVVM (Model-View-ViewModel)
- **Modern iOS Development** - Latest Swift and SwiftUI features
- **Comprehensive Testing** - Multiple testing strategies for reliability  
- **Accessibility First** - Inclusive design for all users
- **Real Backend Integration** - Supabase for production-ready features

## ✨ Features

### Transfer Management
- ✅ **Create** new transfers with recipient details and amounts
- ✅ **Edit** existing transfer information
- ✅ **Delete** transfers with swipe gestures
- ✅ **View** complete transfer history with categorization
- ✅ **Real-time sync** between local SwiftData and Supabase backend
- ✅ **Offline-first** architecture with automatic synchronization

### User Experience
- 🎨 Modern, intuitive SwiftUI interface
- 🌓 Dark mode support
- ♿ Full accessibility support (VoiceOver, Dynamic Type)
- ⚡ Fast, responsive UI with optimistic updates
- 🔄 Background data synchronization
- 📱 Supports iPhone and iPad

## 🏗️ Architecture

**MVVM (Model-View-ViewModel Pattern)**

This project follows the MVVM architecture for maximum testability and separation of concerns:

```
┌─────────────┐
│    View     │ ← SwiftUI Views
│  (SwiftUI)  │
└──────┬──────┘
       │ observes
       ▼
┌──────────────┐
│  ViewModel  │ ← @Observable, manages state & business logic
│             │
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│   Worker    │ ← Data operations (SwiftData + Supabase)
│             │
└──────┬──────┘
       │ uses
       ▼
┌──────────────────────────┐
│  Services                │
│  - SwiftDataService      │
│  - SupabaseService       │
└──────────────────────────┘
```

**Key Components:**
- **View** (SwiftUI) - User interface and user interaction
- **ViewModel** (@Observable) - Business logic, presentation logic, and state management
- **Worker** - Data access layer (SwiftData + Supabase)
- **Services** - External service integrations (Supabase, SwiftData)
- **Router** - Navigation between scenes

## 🛠️ Tech Stack

### Core Technologies
- **SwiftUI** - Declarative UI framework
- **Swift 6.0+** - Latest language features with strict concurrency
- **SwiftData** - Apple's modern persistence framework
- **iOS 17.0+** - Target deployment version
- **Xcode 15.0+** - Development environment

### Backend & Integration
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - REST API client
  - Row Level Security (RLS)
  - Real-time data synchronization
  - Authentication

### Modern Concurrency
- **async/await** - Swift's native concurrency
- **@MainActor** - Thread-safe UI updates
- **Actors** - Safe concurrent data access
- **Structured concurrency** - Proper task management
- **@Observable** macro - Modern state management

### Accessibility
- ✅ **VoiceOver** support with descriptive labels
- ✅ **Dynamic Type** - Text scales with user preferences
- ✅ **High Contrast** mode support
- ✅ **Reduce Motion** animation preferences
- ✅ **WCAG 2.1 AA** compliant color contrast

## 🧪 Testing Strategy

Comprehensive test coverage using **Swift Testing** framework (5 test suites):

### 1. Unit Tests (`UnitTests/`)
- ViewModel logic validation
- Business logic testing
- Presentation logic
- Data formatting
- Worker data operations
- Mock-based isolation
- **Target: 80%+ code coverage**

### 2. UI Tests (`UITests/`)
- User interaction flows
- Navigation patterns
- Form validation
- Button taps and gestures
- Screen transitions

### 3. Integration Tests (`IntegrationTests/`)
- SwiftData persistence
- Supabase API integration
- Worker + Service integration
- Network error handling
- Data synchronization

### 4. Snapshot Tests (`SnapshotTests/`)
- UI regression prevention
- Layout validation across devices (iPhone SE, iPhone 15, iPad Pro)
- Dark/Light mode verification
- Dynamic Type testing
- Accessibility size categories

### 5. End-to-End Tests (`E2ETests/`)
- Complete user journeys
- Transfer creation workflow
- Edit and delete operations
- Real Supabase API interactions
- Full stack integration

## 📦 Project Structure

```
Transfers/
├── Transfers/
│   ├── TransfersApp.swift              # App entry point
│   ├── Secrets.swift                    # Supabase configuration
│   │
│   ├── Scenes/                          # MVVM scenes
│   │   ├── TransferList/                # Main list screen
│   │   │   ├── TransferListView.swift
│   │   │   ├── TransferListViewModel.swift
│   │   │   └── TransferListContent.swift
│   │   │
│   │   ├── TransferDetail/              # Detail view screen
│   │   │   ├── TransferDetailView.swift
│   │   │   └── TransferDetailViewModel.swift
│   │   │
│   │   ├── AddTransfer/                 # Create new transfer
│   │   │   ├── AddTransferView.swift
│   │   │   └── AddTransferViewModel.swift
│   │   │
│   │   └── EditTransfer/                # Edit existing transfer
│   │       ├── EditTransferView.swift
│   │       └── EditTransferViewModel.swift
│   │
│   ├── Models/                          # Data models
│   │   ├── TransferEntity.swift         # SwiftData model
│   │   └── TransferViewModel.swift      # Presentation model
│   │
│   ├── Workers/                         # Data layer
│   │   └── TransferWorker.swift         # CRUD operations
│   │
│   ├── Services/                        # External services
│   │   ├── SupabaseService.swift        # Supabase client
│   │   └── SwiftDataService.swift       # SwiftData operations
│   │
│   ├── Components/                      # Reusable UI components
│   │   ├── TransferRow.swift            # List row component
│   │   └── CategoryIcon.swift           # Category icon view
│   │
│   ├── Extensions/                      # Swift extensions
│   │   └── DynamicTypeSize+Extensions.swift
│   │
│   ├── Routing/                         # Navigation
│   │
│   └── Assets.xcassets/                 # Images and colors
│
├── UnitTests/                           # Unit tests
├── UITests/                             # UI tests  
├── IntegrationTests/                    # Integration tests
├── SnapshotTests/                       # Snapshot tests
├── E2ETests/                            # End-to-end tests
│
└── Transfers.xcodeproj/                 # Xcode project
```

## 🚀 Getting Started

### Prerequisites

- **macOS Ventura (13.0+)** or later
- **Xcode 15.0+** - [Download from App Store](https://apps.apple.com/app/xcode/id497799835)
- **iOS 17.0+** - Simulator or physical device
- **Swift 6.0+** - Included with Xcode
- **Supabase Account** - [Sign up for free](https://supabase.com)

### Installation

#### 1. Clone the repository

```bash
git clone https://github.com/kebuenokebueno/transfers.git
cd transfers
```

#### 2. Configure Supabase

**Option A: Use the example configuration (for testing)**

The project includes a pre-configured test Supabase instance in `Transfers/Secrets.swift`. You can use it as-is for initial testing.

**Option B: Use your own Supabase project**

Update `Transfers/Secrets.swift` with your Supabase credentials:

```swift
struct SupabaseConfig {
    static let supabaseURL = "https://your-project.supabase.co"
    static let supabaseAnonKey = "your-anon-key-here"
    static let supabaseTestURL = "https://your-test-project.supabase.co"
    static let supabaseAnonTestKey = "your-test-anon-key-here"
}
```

> **⚠️ Security Note**: Never commit real API keys to a public repository. Consider using environment variables or `.xcconfig` files for production apps.

#### 3. Set up Supabase Database

Run this SQL in your Supabase SQL Editor:

```sql
-- Create transfers table
CREATE TABLE transfers (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_positive BOOLEAN NOT NULL DEFAULT false,
  sync_status TEXT DEFAULT 'synced'
);

-- Enable Row Level Security
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own transfers"
  ON transfers FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own transfers"
  ON transfers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transfers"
  ON transfers FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transfers"
  ON transfers FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX transfers_user_id_idx ON transfers(user_id);
CREATE INDEX transfers_created_at_idx ON transfers(created_at DESC);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_transfers_updated_at 
  BEFORE UPDATE ON transfers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

#### 4. Open in Xcode

```bash
open Transfers.xcodeproj
```

Or double-click `Transfers.xcodeproj` in Finder.

#### 5. Build and Run

- Select a simulator (e.g., **iPhone 15 Pro**) or connect a physical device
- Press `Cmd + R` or click the ▶️ Run button
- The app will build and launch

## 🧪 Running Tests

### Run All Tests

```bash
# From Xcode
Cmd + U

# From Terminal
xcodebuild test -scheme Transfers -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Run Specific Test Suites

```bash
# Unit Tests only
xcodebuild test -scheme Transfers -only-testing:UnitTests

# UI Tests
xcodebuild test -scheme Transfers -only-testing:UITests

# Integration Tests
xcodebuild test -scheme Transfers -only-testing:IntegrationTests

# Snapshot Tests
xcodebuild test -scheme Transfers -only-testing:SnapshotTests

# E2E Tests (requires Supabase connection)
xcodebuild test -scheme Transfers -only-testing:E2ETests
```

## ♿ Accessibility

Full accessibility support including:

- ✅ VoiceOver with descriptive labels
- ✅ Dynamic Type (Extra Small → Accessibility XXX-Large)
- ✅ High Contrast mode
- ✅ Reduce Motion support
- ✅ WCAG 2.1 AA compliant (4.5:1 minimum contrast)

**Test Accessibility:**
- VoiceOver: `Cmd + F5` in Simulator
- Dynamic Type: Settings → Accessibility → Display & Text Size
- Accessibility Inspector: Xcode → Open Developer Tool

## 🔐 Security

- ✅ **Row Level Security (RLS)** - Users can only access their own data
- ✅ **Authentication Required** - All operations require valid session
- ✅ **HTTPS Only** - All network communication encrypted
- ✅ **Input Validation** - Client and server-side validation
- ✅ **No Sensitive Logs** - User data never appears in console

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 kebuenokebueno

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Author

**kebuenokebueno**
- GitHub: [@kebuenokebueno](https://github.com/kebuenokebueno)
- Repository: [transfers](https://github.com/kebuenokebueno/transfers)

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) - Backend infrastructure
- [Swift.org](https://swift.org) - Swift language
- [Apple Developer](https://developer.apple.com) - SwiftUI, SwiftData, iOS frameworks
- [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) - Snapshot testing library

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)

---

**⭐ If you found this project helpful, please give it a star!**

**🐛 Found a bug? [Open an issue](https://github.com/kebuenokebueno/transfers/issues)**

**💡 Feature request? [Start a discussion](https://github.com/kebuenokebueno/transfers/discussions)**
