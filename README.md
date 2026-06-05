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

| Shortcut | Action |
| --- | --- |
| `Space` | Play / Pause |
| `Arrow Left` | Previous Song |
| `Arrow Right` | Next Song |

## Learning Outcomes

- DOM Manipulation
- Event Listeners
- Fetch API
- Async/Await
- Audio API
- Responsive Design
- CSS Grid / Flexbox

## Challenges Faced

- Loading music folders dynamically in a browser environment
- Synchronizing seekbar progress with audio playback
- Managing responsive layout across desktop and mobile screen sizes
- Building playlist and album UI dynamically with JavaScript

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
