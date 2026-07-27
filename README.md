# PassMe ✈️

PassMe is a language translation assistant built for international travellers. It helps users prepare for travel by generating Q&A pairs in their destination country's language — covering common airport, immigration, and travel scenarios — so they can navigate foreign-language environments with confidence.

---

## Features

- **Flight management** — add and track upcoming trips by origin, destination, and date
- **Language preparation** — generates contextual Q&A content tailored to the destination country's language
- **User accounts** — register, login, and manage your profile (username & password)
- **JWT authentication** — secure, token-based access across all protected endpoints
- **Cross-platform** — web app (Next.js) and mobile app (Flutter) backed by the same REST API

---

## Project Structure

```
passme/
├── backend/        # Go REST API (Gin + MongoDB)
├── mobile/         # Flutter mobile app
└── web/            # Next.js web app
```

---

## Tech Stack

| Layer    | Technology                                      |
|----------|-------------------------------------------------|
| Backend  | Go, Gin, MongoDB, JWT, Docker                   |
| Web      | Next.js 15, React 19, Redux Toolkit, Tailwind   |
| Mobile   | Flutter, Bloc, Dio/HTTP, GetIt, SharedPrefs      |

---

## Backend

### Prerequisites

- Go 1.24+
- MongoDB (local or Atlas)
- Docker & Docker Compose (optional)

### Environment Setup

Copy the example env file and fill in your MongoDB URI:

```bash
cp backend/.env.example backend/.env
```

```env
MONGO_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/?retryWrites=true&w=majority
```

### Run Locally

```bash
cd backend
go run delivery/main.go
```

Server starts on `http://localhost:8080`.

### Run with Docker Compose

```bash
cd backend
docker-compose up --build
```

This spins up both the API and a MongoDB instance.

### API Endpoints

#### Auth

| Method | Endpoint  | Description        | Auth |
|--------|-----------|--------------------|------|
| POST   | /register | Register a user    | No   |
| POST   | /login    | Login, get token   | No   |

#### Profile

| Method | Endpoint           | Description       | Auth |
|--------|--------------------|-------------------|------|
| GET    | /profile/          | Get own profile   | Yes  |
| PUT    | /profile/username  | Change username   | Yes  |
| PUT    | /profile/password  | Change password   | Yes  |

#### Flights

| Method | Endpoint      | Description                   | Auth |
|--------|---------------|-------------------------------|------|
| POST   | /flights      | Create a flight entry         | Yes  |
| GET    | /flights      | Get all flights for user      | Yes  |
| GET    | /flights/:id  | Get a specific flight         | Yes  |
| DELETE | /flights/:id  | Delete a flight               | Yes  |

All protected endpoints require an `Authorization: Bearer <token>` header.

### Run Tests

```bash
cd backend
go test ./...
```

---

## Web

### Prerequisites

- Node.js 18+
- npm

### Setup & Run

```bash
cd web
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Run Tests

```bash
cd web
npm test
```

---

## Mobile

### Prerequisites

- Flutter SDK 3.5+
- Android Studio or Xcode for device/emulator

### Setup & Run

```bash
cd mobile
flutter pub get
flutter run
```

### Environment

Create a `.env` file inside the `mobile/` directory:

```env
BASE_URL=http://localhost:8080
```

### Run Tests

```bash
cd mobile
flutter test
```

---

## CI/CD

The backend includes a GitHub Actions workflow at `.github/workflows/ci-cd.yml` that runs tests and builds on every push.

---

## License

This project was built as part of the A2SV 2025 Internship Program.
