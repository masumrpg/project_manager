# TODO: Migrasi Catatan Kaki ke Offline-First

## 🖥️ Platform Support

**Semua OS Supported:**
- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ Windows
- ✅ macOS
- ✅ Web

---

## 📦 Dependencies Baru

**Tambah:**
- `drift` - Local database (semua platform)
- `sqlite3_flutter_libs` - SQLite native (Android/iOS/Desktop)
- `sqlite3` - SQLite WASM fallback (Web)
- `path_provider` - File paths
- `flutter_riverpod` - State management (ganti provider)
- `dio` - HTTP client (ganti http)
- `connectivity_plus` - Network detection
- `freezed_annotation` - Immutable models
- `json_annotation` - JSON serialization
- `flutter_secure_storage` - Secure storage
- `workmanager` - Background tasks (Android/iOS)
- `logger` - Logging

**Dev dependencies:**
- `drift_dev` - Code generator
- `build_runner` - Build tool
- `freezed` - Code generator
- `json_serializable` - JSON generator

**Hapus:**
- `provider`
- `http`

---

## ➕ Fitur Baru

### Offline Capability
- [ ] Semua CRUD (projects, notes, todos, revisions) bisa offline
- [ ] Auto-save ke local database
- [ ] Queue operations untuk sync nanti

### Sync Features
- [ ] Manual sync via pull-to-refresh
- [ ] Auto background sync (setiap 15 menit)
- [ ] Sync status indicator (synced/pending/syncing/error)
- [ ] Last synced timestamp display
- [ ] Pending sync count badge

### Conflict Resolution
- [ ] Detect conflicts by version number
- [ ] Auto-resolve dengan Last-Write-Wins
- [ ] Show conflict notification (optional manual resolve)

### Better UX
- [ ] Offline mode indicator/banner
- [ ] Instant UI updates (no loading spinner untuk CRUD)
- [ ] Network status detection
- [ ] Sync error notifications

### Settings Screen
- [ ] Toggle auto-sync on/off
- [ ] Manual force sync button
- [ ] Clear local cache
- [ ] Storage usage info

---

## 🔧 Technical Changes

### Database
- [ ] Setup Drift dengan 7 tables:
  - users, projects, notes, todos, revisions
  - sync_queue, sync_metadata
- [ ] Pakai field existing `created_at` dan `updated_at` untuk conflict resolution

### Repositories
- [ ] Buat local repository per entity (Drift)
- [ ] Refactor remote repository pakai Dio
- [ ] Buat unified repository (local + remote)
- [ ] Logic: Save local first, queue for sync

### Sync Engine
- [ ] SyncService - orchestrate push/pull
- [ ] ConflictResolver - handle conflicts
- [ ] SyncQueueProcessor - retry failed ops
- [ ] ConnectivityService - monitor network

### State Management
- [ ] Migrate semua Provider ke Riverpod
- [ ] Stream dari Drift untuk reactive UI
- [ ] Provider untuk connectivity status

### Auth
- [ ] Migrate token ke flutter_secure_storage
- [ ] Allow offline access dengan cached data
- [ ] Re-sync setelah re-authenticate

---

## ✅ Checklist

### Setup
- [ ] Add dependencies
- [ ] Setup Drift database
- [ ] Convert models ke Freezed
- [ ] Generate code (build_runner)

### Repositories
- [ ] Local repos (Drift CRUD)
- [ ] Remote repos (Dio + interceptors)
- [ ] Unified repos (combine both)
- [ ] Sync queue repo

### Sync
- [ ] Sync service (push/pull logic)
- [ ] Conflict resolver
- [ ] Background sync per platform:
  - **Android**: `workmanager` (full support, bisa periodic task)
  - **iOS**: `workmanager` (terbatas, fallback ke foreground sync)
  - **Desktop** (Linux/Windows/macOS): `Timer.periodic` internal app
  - **Web**: `Timer.periodic` saat tab aktif (atau service worker PWA)
- [ ] Connectivity monitoring

### UI Updates
- [ ] Add sync indicators semua screens
- [ ] Pull-to-refresh di lists
- [ ] Offline banner component
- [ ] Settings screen baru
- [ ] Update dashboard (add sync info)

### Testing
- [ ] Unit test repos
- [ ] Unit test sync service
- [ ] Integration test offline flow
- [ ] Test conflict scenarios

---

## 🚀 Quick Start Order

1. Setup database + models (Drift + Freezed)
2. Buat local repositories
3. Update UI pakai local repos (offline CRUD works)
4. Refactor remote repos pakai Dio
5. Build sync service
6. Add background sync
7. Polish UI (indicators, banners, etc)
8. Testing

**Estimated**: 4-6 minggu

---

## 📝 Notes

- Device ID: Generate pakai `uuid`, simpan di secure storage
- Conflict: Default Last-Write-Wins based on `updatedAt` + `version`
- Quill content: Simpan as JSON string di SQLite TEXT column
- First launch: Fetch semua data dari API, populate local DB