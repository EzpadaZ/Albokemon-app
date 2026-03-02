# Albokemon App (Flutter)

Albokemon is a small Pokémon-style demo app built with **Flutter**.  
It connects to a **Socket.IO backend** to handle login, lobby presence, match invites, and a simple turn-based battle.

This repo contains the **frontend app**.

---

## Features

- **Login** with a username
- **Lobby**: list online users
- **Matchmaking**:
  - send battle invite
  - accept / decline invite
  - handle disconnects / invite failures gracefully
- **Battle (MVP)**:
  - server-authoritative turns
  - Pokémon assigned by backend from an external API
  - animated Pokémon **GIF sprites**
  - BGM + SFX
  - damage feedback (flash + floating “-HP”)

---

## Requirements

- **Flutter 3.35.7**
- Android Studio / Android SDK (for Android builds)
- A running backend (local or deployed)

---

## Run the app (development)

```bash
flutter pub get
flutter run
```

## Using your own backend

You have two options when trying to connect to your own backend application

#### Option A
With the application already executing tap **> AJUSTES** then edit the **Server address** to match your backend URL that should look like this:

```http://192.168.X.X:8080```

#### Option B
Inside the following route```/lib/shared/utils/game_manager.dart```
Edit the following var: ```connectionString``` with your desired connection string.

## Project Structure

- `lib/app/login/` → login screen  
- `lib/app/lobby/` → lobby + invites  
- `lib/app/battle/` → battle screen  
- `lib/shared/network/` → socket client + events + session  
- `lib/shared/utils/` → GameManager, audio, logger, navigation, theme  
- `lib/shared/widgets/` → reusable widgets  

## Backend expectations (contract)

### Auth
- `auth/login` → `{ name, metadata? }`
- `auth/ok` → `{ user }`

### Lobby
- `lobby/list`
- `lobby/users` → `{ users: [...] }`
- `lobby/updated` → `{ users: [...] }`

### Match
- `match/request` → `{ targetUserId }`
- `match/invite` → `{ fromUserId, fromName }`
- `match/accept` → `{ fromUserId }`
- `match/decline` → `{ fromUserId }`
- `match/declined` → `{ byUserId, reason? }`
- `match/start` → `{ matchId, roomId, p1, p2, pokemonByPlayerId }`

### Battle
- `battle/sync` → `{ matchId }`
- `battle/state` → `{ matchId, state, events }`
- `battle/attack` → `{ matchId }`