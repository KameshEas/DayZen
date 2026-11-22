# DayZen Documentation

Welcome to the DayZen project documentation. This guide helps you navigate all available resources.

## 📚 Quick Navigation

### For Getting Started
1. **[SESSION_SUMMARY.md](./SESSION_SUMMARY.md)** ← Start here!
   - Overview of what was completed
   - Architecture overview
   - Quick links to other docs

### For Frontend Developers
2. **[IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)**
   - How API integration works
   - How to test the features
   - Configuration details
   - Success criteria

3. **[API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md)**
   - How to add new API endpoints
   - Best practices
   - Error handling patterns
   - Testing examples

4. **[UI_IMPROVEMENTS.md](./UI_IMPROVEMENTS.md)**
   - Recommended UI enhancements
   - Implementation priorities
   - Quick wins (theme toggle is one!)
   - Code examples

### For Backend Developers
5. **[BACKEND_API_SPEC.md](./BACKEND_API_SPEC.md)**
   - API endpoint specifications
   - Request/response formats
   - Error handling standards
   - Planned endpoints
   - Deployment checklist

### For Architecture/Design
6. **[../memory/hardcoded_values_refactor.md](../memory/hardcoded_values_refactor.md)**
   - Why hardcoded values were removed
   - AppConfig structure
   - ContentService pattern
   - DateFormatter utilities

---

## 🎯 Common Tasks

### "I need to add a new API endpoint"
→ Follow [API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md) section: "Adding a New API Endpoint"

### "What APIs do I need to build on the backend?"
→ Check [BACKEND_API_SPEC.md](./BACKEND_API_SPEC.md) - fully documented with request/response examples

### "How do I test the daily quote feature?"
→ See [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) section: "Testing Checklist"

### "How do I configure the API URL?"
→ [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) section: "Configuration"

### "What UI improvements are easy to implement?"
→ [UI_IMPROVEMENTS.md](./UI_IMPROVEMENTS.md) section: "Implementation Priority"

### "Why is the code structured this way?"
→ [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) section: "Integration Architecture"

---

## 📁 Project Structure

```
dayzen/
├── docs/                                    # Documentation (you are here)
│   ├── README.md                           # This file
│   ├── SESSION_SUMMARY.md                  # Overview of what was done
│   ├── IMPLEMENTATION_SUMMARY.md            # How to use API integration
│   ├── API_INTEGRATION_GUIDE.md             # How to add endpoints
│   ├── UI_IMPROVEMENTS.md                  # UI enhancement ideas
│   └── BACKEND_API_SPEC.md                 # API specification
│
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   └── api_client.dart            # HTTP client with retry logic
│   │   ├── config/
│   │   │   └── app_config.dart            # Centralized configuration
│   │   ├── services/
│   │   │   └── content_service.dart       # API integration service
│   │   └── utils/
│   │       └── date_formatter.dart        # Date/time utilities
│   │
│   └── features/
│       ├── home/
│       │   └── home_page.dart             # Uses ContentService for quotes
│       └── settings/
│           ├── settings_page.dart         # Theme toggle UI
│           └── settings_controller.dart   # Theme persistence
│
├── pubspec.yaml                            # Project dependencies
└── memory/
    └── hardcoded_values_refactor.md        # Refactoring documentation
```

---

## 🚀 Quick Start for New Developers

### Step 1: Understand the Architecture (5 min)
Read: [SESSION_SUMMARY.md](./SESSION_SUMMARY.md) → "Integration Architecture" section

### Step 2: See It In Action (10 min)
1. Open `lib/features/home/home_page.dart`
2. Look for `FutureBuilder<String>` with `getDailyReflectionQuote()`
3. Trace through to `lib/core/services/content_service.dart`

### Step 3: Understand the API Client (10 min)
Read: [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) → "API Client Implementation"

### Step 4: Know What to Build (15 min)
Read: [BACKEND_API_SPEC.md](./BACKEND_API_SPEC.md) → "Currently Implemented Endpoints"

### Step 5: Extend It (30 min)
Follow: [API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md) → "Adding a New API Endpoint"

**Total Time: ~70 minutes to be productive**

---

## 📊 Feature Status

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| **API Client** | ✅ Done | `lib/core/api/api_client.dart` | Production ready |
| **Daily Quote** | ✅ Done | `lib/core/services/content_service.dart` | Integrated in home page |
| **Theme Toggle** | ✅ Done | `lib/features/settings/` | Already fully working |
| **AppConfig** | ✅ Done | `lib/core/config/app_config.dart` | 130+ constants |
| **DateFormatter** | ✅ Done | `lib/core/utils/date_formatter.dart` | Consistent formatting |
| **AI Quote API** | 📋 Planned | Will implement similar to daily quote | Documented in spec |
| **Achievements** | 📋 Planned | Endpoint ready in spec | Waiting for backend |
| **Task Scheduling** | 📋 Planned | Endpoint ready in spec | Waiting for backend |

---

## 🔧 Key Technologies

- **Flutter** - UI framework
- **Dart** - Language
- **HTTP** - Network requests (v1.1.0)
- **SharedPreferences** - Local storage
- **Firebase** - Authentication (optional)

---

## 💡 Key Concepts

### 1. AppConfig (Centralized Configuration)
All hardcoded constants are in one place for easy management.

```dart
// Instead of: "Good Morning", "Good Afternoon", "Good Evening"
// Use: AppConfig.greetingMorning, AppConfig.greetingAfternoon, etc.
```

### 2. ContentService (API Integration with Fallbacks)
Fetches dynamic content from APIs, with sensible defaults.

```dart
// Automatically tries API first, falls back to AppConfig if API fails
final quote = await ContentService.instance.getDailyReflectionQuote();
```

### 3. DateFormatter (Consistent Date Formatting)
Single source of truth for date/time formatting.

```dart
// Centralized: no duplicate month/weekday arrays
final formatted = DateFormatter.formatDate(DateTime.now());
```

### 4. ApiClient (Robust HTTP)
HTTP client with automatic retry and proper error handling.

```dart
// Handles timeouts, retries, and errors gracefully
final response = await ApiClient().get('/quotes/daily');
```

---

## 🧪 Testing

### Unit Tests
Check [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) → "Testing Checklist"

### Manual Testing
1. Follow the checklist in [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)
2. Test with network disabled
3. Test with API timeout (use network throttling)
4. Test theme toggle

### Backend Testing
Use json-server mock as described in [BACKEND_API_SPEC.md](./BACKEND_API_SPEC.md)

---

## 📞 Common Questions

**Q: Where do I add a new API endpoint?**  
A: Follow [API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md)

**Q: What happens if the API is down?**  
A: App uses sensible defaults from AppConfig - never crashes

**Q: How do I change the theme?**  
A: Settings page → "Light/Dark Mode" (already works!)

**Q: How is the code organized?**  
A: See "Project Structure" section above

**Q: What's the difference between AppConfig and ContentService?**  
A: 
- **AppConfig** = Static defaults (no network needed)
- **ContentService** = Dynamic content from API (with AppConfig fallback)

**Q: Where are all the quotes coming from?**  
A: 
- Primary: API endpoint `/quotes/daily` (fetched by ContentService)
- Fallback: `AppConfig.defaultDailyReflectionQuote` (if API unavailable)

---

## 🎓 Learning Path

1. **Beginner** (New to project)
   - Read: SESSION_SUMMARY.md
   - Read: IMPLEMENTATION_SUMMARY.md
   - Run: App and see daily quote work

2. **Intermediate** (Want to extend)
   - Read: API_INTEGRATION_GUIDE.md
   - Read: BACKEND_API_SPEC.md
   - Write: One new endpoint

3. **Advanced** (Architectural understanding)
   - Read: hardcoded_values_refactor.md
   - Read: All docs thoroughly
   - Plan: Next features

---

## 📚 Documentation Maintenance

These docs are updated whenever:
- New endpoints are added to the API
- Architecture changes
- Configuration changes
- Testing procedures change

Last updated: June 13, 2026

---

## 🤝 Contributing

When adding new features:
1. Update relevant documentation
2. Add to [UI_IMPROVEMENTS.md](./UI_IMPROVEMENTS.md) if applicable
3. Update this README if structure changes
4. Follow patterns in existing code

---

## 📝 Quick Reference

### Files to Know
- `lib/core/api/api_client.dart` - How HTTP requests work
- `lib/core/services/content_service.dart` - How API integration works
- `lib/core/config/app_config.dart` - All the constants
- `lib/features/home/home_page.dart` - Example integration

### Commands
```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Build release
flutter build apk
```

### Configuration
- API URL: `lib/core/api/api_client.dart:5`
- Timeout: `lib/core/api/api_client.dart:6`
- Cache duration: `lib/core/services/content_service.dart`

---

**Happy coding! 🚀**

*For questions, check the relevant documentation above or review the code comments.*
