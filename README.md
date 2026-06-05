# Spotify Clone H

![Spotify Clone H](https://img.shields.io/badge/Project-Spotify%20Clone%20H-blue)
![Frontend](https://img.shields.io/badge/Frontend-HTML%2FCSS%2FJavaScript-green)
![No Backend](https://img.shields.io/badge/Backend-None-important)

## Overview

Spotify Clone H is a frontend music streaming web application inspired by the Spotify Web Player. It is a learning project built with pure HTML, CSS, and JavaScript. The app uses local folders for music organization, dynamic playlist generation, and browser audio playback without any backend or database.

## Features

- Dynamic playlist loading from local folders
- Dynamic album card generation
- Play / pause controls
- Previous / next song navigation
- Seekbar with current time and duration display
- Volume control and mute/unmute
- Keyboard shortcuts support
- Fully responsive layout
- Mobile sidebar navigation
- Hover animations and modern UI styling
- Dynamic folder-based music organization

## Screenshots

> Add your screenshots here

- `screenshot-1.png`
- `screenshot-2.png`
- `screenshot-3.png`

## Demo

> Add your deployed link here

[Live Demo](https://example.com)

## Technologies Used

- HTML5
- CSS3
- JavaScript (ES6+)
- Fetch API
- Async/Await
- Audio API
- Responsive design with Flexbox

## Project Structure

```plaintext
spotify-clone-h/
├── index.html
├── style.css
├── utility.css
├── Refactored.css
├── script.js
├── img/
├── songs/
│   ├── cs/
│   ├── ncs/
│   ├── Finding Her/
│   └── ...
└── README.md
```

## How It Works

### Dynamic playlists

The app loads music files from local `songs/` folders using the Fetch API. It reads folder links and builds the playlist dynamically in the sidebar library.

### Dynamic album cards

Album cards are generated in JavaScript by reading song folder metadata and rendering card markup for each album folder found in `songs/`.

### Audio player logic

The music player uses the JavaScript `Audio` API. When a track is selected, the audio source is updated and playback begins. The player updates the current playback time, duration display, and seekbar position in real time.

### Event handling

Buttons, song cards, and playlist items use DOM event listeners to handle user interaction. Click events trigger play/pause, track selection, and volume adjustments. The seekbar listens for click and drag events to update playback position.

### Keyboard controls

The application supports keyboard shortcuts for improved accessibility and user experience.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/spotify-clone-h.git
   ```
2. Open the project folder in VS Code or your preferred editor.
3. Launch a local development server:
   - Use VS Code Live Server
   - Or use a command-line server like `http-server`
4. Open `index.html` in the browser through the local server.
5. Ensure the `songs/` folder is accessible so the app can load local audio files.

## Keyboard Shortcuts

| Shortcut      | Action        |
| ------------- | ------------- |
| `Space`       | Play / Pause  |
| `Arrow Left`  | Previous Song |
| `Arrow Right` | Next Song     |

## Learning Outcomes

- DOM Manipulation
- Event Listeners
- Fetch API
- Async/Await
- Audio API
- Responsive Design
- CSS Grid / Flexbox

## Challenges Faced

### Development Issues and Solutions

This section documents common errors encountered during development and deployment, with solutions applied.

#### 1. **Error: `net::ERR_CONNECTION_REFUSED` & `Failed to fetch`**

**Problem:**

```
Failed to load resource: net::ERR_CONNECTION_REFUSEDUnderstand this error
script.js:19  Uncaught (in promise) TypeError: Failed to fetch
```

**Cause:** Hardcoded localhost URL in fetch requests:

```javascript
// ❌ WRONG - Only works on local machine
fetch(`http://127.0.0.1:5500/projects/Spotify%20clone%20H/${folder}`);
```

When deployed to Netlify, this address doesn't exist, causing connection refused errors.

**Solution:** Use relative paths instead:

```javascript
// ✅ CORRECT - Works anywhere
fetch(`songs/${folder}`);
```

**Lesson:** Always use relative paths for assets and API calls that should work across different environments.

---

#### 2. **Error: `Cannot read properties of undefined (reading 'split')`**

**Problem:**

```
script.js:79 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'split')
    at playMusic (script.js:79:11)
    at main (script.js:134:3)
```

**Cause:** Attempting to play a song when the `songs` array was empty (due to 404 error from Issue #1). The code tried to call `songs[0]` which was `undefined`, then tried to call `.split()` on it.

**Solution:** Add defensive null checks before using variables:

```javascript
const playMusic = (track, pause = false) => {
  if (!track) {
    console.warn("No track provided to playMusic");
    return; // Exit early if no track
  }
  // ... rest of code
};
```

Also check if songs array has content before accessing:

```javascript
if (songs && songs.length > 0) {
  playMusic(songs[0], true);
} else {
  console.warn("No songs found in the specified folder");
}
```

**Lesson:** Always validate data before using it, especially with array access and method calls.

---

#### 3. **Error: `Failed to load resource: 404` - Directory Listing Not Available**

**Problem:**

```
Failed to load resource: the server responded with a status of 404 ()
script.js:22 Failed to load folder: songs/cs 404
/songs/:1 Failed to load resource: the server responded with a status of 404 ()
```

**Cause:** The code relied on fetching a directory listing from `songs/` folder:

```javascript
// ❌ WRONG - Requires directory listing enabled
fetch("songs/"); // Expects HTML directory listing response
```

Netlify (and most production servers) disable directory listing by default for security reasons. The fetch returns 404 because there's no actual file at that path.

**Solution:** Create a `manifest.json` file explicitly listing all albums:

```json
{
  "albums": [
    {
      "folder": "cs",
      "title": "copyright songs",
      "description": "songs you like the most"
    },
    {
      "folder": "ncs",
      "title": "NCS",
      "description": "No Copyright Sounds"
    }
  ]
}
```

Then fetch from the manifest instead:

```javascript
// ✅ CORRECT - Uses explicit manifest
let response = await fetch("songs/manifest.json");
let manifest = await response.json();

for (const album of manifest.albums) {
  // Render album cards
}
```

**Lesson:** Don't rely on server features like directory listing in production. Always use explicit configuration files (JSON manifests, config files, etc.).

---

#### 4. **Error: `AbortError: The play() request was interrupted by a call to pause()`**

**Problem:**

```
Uncaught (in promise) AbortError: The play() request was interrupted by a call to pause().
https://goo.gl/LdLk22
```

**Cause:** The `play()` method returns a Promise in modern browsers. If `pause()` is called before the promise resolves, the browser throws an AbortError.

```javascript
// ❌ WRONG - No error handling
currentSong.play(); // Returns a Promise that might reject
```

**Solution:** Catch the promise and handle errors:

```javascript
// ✅ CORRECT - Handles promise rejection
const playPromise = currentSong.play();
if (playPromise !== undefined) {
  playPromise.catch((error) => {
    console.log("Play interrupted:", error);
  });
}
```

**Lesson:** Always handle Promises properly, especially for APIs like Audio that might reject.

---

#### 5. **Error: App Works Locally but Not on Netlify**

**Root Cause:** Multiple issues combined:

1. Hardcoded localhost URLs
2. No error handling for failed fetches
3. Reliance on server directory listing
4. No graceful degradation when songs aren't available

**Complete Solution Applied:**

- ✅ Replaced all localhost URLs with relative paths
- ✅ Added try-catch blocks to all fetch calls
- ✅ Created `songs/manifest.json` for album data
- ✅ Added null/undefined checks before using data
- ✅ Added promise error handling for audio playback
- ✅ Set default album to one known to have songs

**Result:** App now works seamlessly on both local development server and Netlify.

---

### Key Deployment Checklist

- [ ] No hardcoded URLs (localhost, specific paths, etc.)
- [ ] All fetches are from relative paths or explicit config files
- [ ] Error handling for all async operations
- [ ] Null/undefined checks before accessing properties
- [ ] Promise error handling for APIs
- [ ] All required assets included (CSS, images, audio files)
- [ ] Static manifest/config files instead of relying on server features
- [ ] Browser console shows no errors or warnings
- [ ] Works offline (where applicable)

---

## Challenges Faced (General)

- Loading music folders dynamically in a browser environment
- Synchronizing seekbar progress with audio playback
- Managing responsive layout across desktop and mobile screen sizes
- Building playlist and album UI dynamically with JavaScript
- Handling cross-origin and CORS issues
- Managing audio playback state across different browsers

## Future Improvements

- Add search functionality for songs and albums
- Add user accounts and personalized playlists
- Add favorites / liked songs management
- Add playlist creation and editing features
- Integrate a backend for persistent user data
- Integrate with the Spotify API for real music metadata

## Author

**Om**

Frontend developer building interactive web experiences with HTML, CSS, and JavaScript.

Connect with me on GitHub: [your-github-profile](https://github.com/your-username)
