# Project Manager

Aplikasi manajemen proyek yang dibangun dengan Flutter untuk membantu mengelola proyek, catatan, revisi, dan tugas dengan antarmuka yang modern dan intuitif.

## 📱 Fitur Utama

### 🎯 Manajemen Proyek
- **Kategori Proyek**: Personal, Work, Study, Health, Finance, Travel, Shopping, Entertainment, Family, Other
- **Environment**: Development, Staging, Production, Testing, Local
- **Deskripsi Panjang**: Editor rich text untuk dokumentasi detail proyek
- **Tracking**: Tanggal pembuatan dan update otomatis

### 📝 Sistem Catatan
- **Rich Text Editor**: Menggunakan Flutter Quill untuk editing yang powerful
- **Status Management**: Active/Inactive notes
- **Pencarian**: Cari catatan berdasarkan judul dan konten
- **Organisasi**: Catatan terhubung langsung dengan proyek

### 🔄 Manajemen Revisi
- **Version Control**: Tracking versi dengan deskripsi perubahan
- **Status Tracking**: Pending, Approved, Rejected
- **Change Log**: Dokumentasi detail perubahan setiap revisi
- **Timeline**: Riwayat kronologis semua revisi

### ✅ Todo Management
- **Priority Levels**: High, Medium, Low
- **Status Tracking**: Pending, In Progress, Completed, Cancelled, On Hold
- **Due Dates**: Pengingat deadline tugas
- **Rich Content**: Deskripsi detail untuk setiap tugas

### 👤 User Management
- **Profile**: Nama dan role pengguna
- **Onboarding**: Setup awal untuk pengguna baru
- **Personalisasi**: Pengaturan preferensi pengguna

## 🎨 Design System

### Color Palette
- **Primary**: `#E07A5F` (Accent Orange)
- **Secondary**: `#F5E6D3` (Primary Beige)
- **Background**: `#FFFBF7` (Card Background)
- **Text**: `#2D3436` (Dark Text)

### UI Components
- **Material 3**: Design system terbaru dari Google
- **Responsive**: Mendukung mobile, tablet, dan desktop
- **Animations**: Transisi halus dan feedback visual
- **Accessibility**: Mendukung screen reader dan navigasi keyboard

## 🏗️ Arsitektur Aplikasi

### State Management
- **Provider Pattern**: Untuk state management yang scalable
- **Repository Pattern**: Abstraksi layer data
- **Service Layer**: Handling business logic

### Data Persistence
- **Hive Database**: NoSQL database lokal yang cepat
- **Type Adapters**: Serialisasi otomatis untuk model kompleks
- **Lazy Loading**: Optimasi performa untuk data besar

## 📊 Flow Aplikasi

```mermaid
flowchart TD
    A[App Start] --> B[Splash Screen]
    B --> C{Onboarding Complete?}
    C -->|No| D[Onboarding Screen]
    C -->|Yes| E[Home Screen]
    D --> F[User Setup]
    F --> E
    
    E --> G[Project List]
    G --> H[Project Detail]
    H --> I[Notes Management]
    H --> J[Todo Management]
    H --> K[Revision Management]
    H --> L[Long Description Editor]
    
    I --> M[Note Detail]
    M --> N[Rich Text Editor]
    
    J --> O[Todo Detail]
    O --> P[Priority & Status]
    
    K --> Q[Revision Detail]
    Q --> R[Version History]
    
    L --> S[Markdown Editor]
    
    style A fill:#E07A5F,stroke:#333,stroke-width:2px,color:#fff
    style E fill:#F5E6D3,stroke:#333,stroke-width:2px
    style H fill:#F5E6D3,stroke:#333,stroke-width:2px
```

## 🗄️ Database Schema

```mermaid
erDiagram
    USER {
        string id PK
        string name
        string role
        string avatar_url
        datetime created_at
        datetime updated_at
    }
    
    PROJECT {
        string id PK
        string user_id FK
        string title
        string description
        jsonb long_description
        enum category
        enum environment
        datetime created_at
        datetime updated_at
    }
    
    NOTE {
        string id PK
        string project_id FK
        string title
        string description
        jsonb content
        enum status
        datetime created_at
        datetime updated_at
    }
    
    TODO {
        string id PK
        string project_id FK
        string title
        string description
        jsonb content
        enum priority
        enum status
        datetime due_date
        datetime created_at
        datetime completed_at
    }
    
    REVISION {
        string id PK
        string project_id FK
        string version
        string description
        jsonb changes
        enum status
        datetime created_at
    }
    
    USER ||--o{ PROJECT : "owns"
    PROJECT ||--o{ NOTE : "has many"
    PROJECT ||--o{ TODO : "has many"
    PROJECT ||--o{ REVISION : "has many"
```

## 🐘 PostgreSQL Schema untuk Deployment Online

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- App categories enum
CREATE TYPE app_category AS ENUM (
    'personal', 'work', 'study', 'health', 'finance', 
    'travel', 'shopping', 'entertainment', 'family', 'other'
);

-- Environment enum
CREATE TYPE environment_type AS ENUM (
    'development', 'staging', 'production', 'testing', 'local'
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    long_description JSONB, -- Quill editor content
    category app_category NOT NULL,
    environment environment_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Note status enum
CREATE TYPE note_status AS ENUM ('active', 'inactive');

-- Notes table
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content JSONB NOT NULL, -- Quill editor content
    status note_status DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Todo priority and status enums
CREATE TYPE todo_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE todo_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled', 'on_hold');

-- Todos table
CREATE TABLE todos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    content JSONB, -- Quill editor content
    priority todo_priority NOT NULL,
    status todo_status DEFAULT 'pending',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Revision status enum
CREATE TYPE revision_status AS ENUM ('pending', 'approved', 'rejected');

-- Revisions table
CREATE TABLE revisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    version VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    changes JSONB NOT NULL, -- Quill editor content
    status revision_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_category ON projects(category);
CREATE INDEX idx_projects_environment ON projects(environment);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);

-- JSONB indexes for Quill content search
CREATE INDEX idx_projects_long_description_gin ON projects USING GIN (long_description);

CREATE INDEX idx_notes_project_id ON notes(project_id);
CREATE INDEX idx_notes_status ON notes(status);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);

-- JSONB indexes for Quill content search
CREATE INDEX idx_notes_content_gin ON notes USING GIN (content);

CREATE INDEX idx_todos_project_id ON todos(project_id);
CREATE INDEX idx_todos_status ON todos(status);
CREATE INDEX idx_todos_priority ON todos(priority);
CREATE INDEX idx_todos_due_date ON todos(due_date);
CREATE INDEX idx_todos_created_at ON todos(created_at DESC);

-- JSONB indexes for Quill content search
CREATE INDEX idx_todos_content_gin ON todos USING GIN (content);

CREATE INDEX idx_revisions_project_id ON revisions(project_id);
CREATE INDEX idx_revisions_status ON revisions(status);
CREATE INDEX idx_revisions_created_at ON revisions(created_at DESC);

-- JSONB indexes for Quill content search
CREATE INDEX idx_revisions_changes_gin ON revisions USING GIN (changes);

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for auto-updating timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON notes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## 🚀 Setup dan Instalasi

### Prerequisites
- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code
- Git

### Local Development
```bash
# Clone repository
git clone <repository-url>
cd project_manager

# Install dependencies
flutter pub get

# Generate code (untuk Hive adapters)
flutter packages pub run build_runner build

# Run aplikasi
flutter run
```

### Dependencies Utama
```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3              # NoSQL database
  hive_flutter: ^1.1.0      # Flutter integration
  provider: ^6.1.5+1        # State management
  flutter_quill: 11.4.2     # Rich text editor
  uuid: ^4.5.1              # UUID generation
  intl: ^0.20.2             # Internationalization
  animated_splash_screen: ^1.3.0
  page_transition: ^2.1.0
  flutter_markdown: ^0.7.7+1
```

## 🌐 Deployment Online

### Backend Setup (Node.js + PostgreSQL)
1. **Database Setup**:
   ```bash
   # Install PostgreSQL
   # Create database
   createdb project_manager_db
   
   # Run schema
   psql -d project_manager_db -f schema.sql
   ```

2. **API Server**:
   ```bash
   # Setup Node.js backend
   npm init -y
   npm install express pg cors helmet dotenv
   npm install -D nodemon
   ```

3. **Environment Variables**:
   ```env
   DATABASE_URL=postgresql://username:password@localhost:5432/project_manager_db
   PORT=3000
   JWT_SECRET=your-secret-key
   ```

### Flutter Web Deployment
```bash
# Build untuk web
flutter build web

# Deploy ke hosting (Netlify/Vercel/Firebase)
# Upload folder build/web
```

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

Project Link: [https://github.com/username/project_manager](https://github.com/username/project_manager)

---

**Dibuat dengan ❤️ menggunakan Flutter**