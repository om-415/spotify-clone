$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$projectRoot = Split-Path -Parent $PSScriptRoot
$outFile = Join-Path $projectRoot "Spotify_Clone_Project_Report.docx"
$buildDir = Join-Path $projectRoot ("tools\docx_build_" + [System.Guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "_rels") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "docProps") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "word") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "word\_rels") | Out-Null

function Escape-Xml {
    param([string]$Text)
    if ($null -eq $Text) { return "" }
    return [System.Security.SecurityElement]::Escape($Text)
}

$body = New-Object System.Collections.Generic.List[string]

function Add-Paragraph {
    param(
        [string]$Text,
        [string]$Style = "Normal",
        [bool]$Bold = $false,
        [bool]$Italic = $false
    )
    $b = if ($Bold) { "<w:b/>" } else { "" }
    $i = if ($Italic) { "<w:i/>" } else { "" }
    $body.Add("<w:p><w:pPr><w:pStyle w:val=`"$Style`"/></w:pPr><w:r><w:rPr>$b$i</w:rPr><w:t xml:space=`"preserve`">$(Escape-Xml $Text)</w:t></w:r></w:p>")
}

function Add-Heading {
    param([string]$Text, [int]$Level = 1)
    Add-Paragraph -Text $Text -Style "Heading$Level"
}

function Add-Bullet {
    param([string]$Text)
    $body.Add("<w:p><w:pPr><w:pStyle w:val=`"ListParagraph`"/><w:numPr><w:ilvl w:val=`"0`"/><w:numId w:val=`"1`"/></w:numPr></w:pPr><w:r><w:t xml:space=`"preserve`">$(Escape-Xml $Text)</w:t></w:r></w:p>")
}

function Add-Number {
    param([string]$Text)
    $body.Add("<w:p><w:pPr><w:pStyle w:val=`"ListParagraph`"/><w:numPr><w:ilvl w:val=`"0`"/><w:numId w:val=`"2`"/></w:numPr></w:pPr><w:r><w:t xml:space=`"preserve`">$(Escape-Xml $Text)</w:t></w:r></w:p>")
}

function Add-PageBreak {
    $body.Add("<w:p><w:r><w:br w:type=`"page`"/></w:r></w:p>")
}

function Add-Table {
    param(
        [string[]]$Headers,
        [object[]]$Rows,
        [int[]]$Widths
    )
    $grid = ($Widths | ForEach-Object { "<w:gridCol w:w=`"$_`"/>" }) -join ""
    $xml = "<w:tbl><w:tblPr><w:tblW w:w=`"9360`" w:type=`"dxa`"/><w:tblInd w:w=`"120`" w:type=`"dxa`"/><w:tblBorders><w:top w:val=`"single`" w:sz=`"6`" w:space=`"0`" w:color=`"D9E2EC`"/><w:left w:val=`"single`" w:sz=`"6`" w:space=`"0`" w:color=`"D9E2EC`"/><w:bottom w:val=`"single`" w:sz=`"6`" w:space=`"0`" w:color=`"D9E2EC`"/><w:right w:val=`"single`" w:sz=`"6`" w:space=`"0`" w:color=`"D9E2EC`"/><w:insideH w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"E5E7EB`"/><w:insideV w:val=`"single`" w:sz=`"4`" w:space=`"0`" w:color=`"E5E7EB`"/></w:tblBorders><w:tblCellMar><w:top w:w=`"90`" w:type=`"dxa`"/><w:left w:w=`"140`" w:type=`"dxa`"/><w:bottom w:w=`"90`" w:type=`"dxa`"/><w:right w:w=`"140`" w:type=`"dxa`"/></w:tblCellMar></w:tblPr><w:tblGrid>$grid</w:tblGrid>"
    $xml += "<w:tr><w:trPr><w:tblHeader/></w:trPr>"
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $xml += "<w:tc><w:tcPr><w:tcW w:w=`"$($Widths[$i])`" w:type=`"dxa`"/><w:shd w:val=`"clear`" w:fill=`"F2F4F7`"/></w:tcPr><w:p><w:pPr><w:pStyle w:val=`"TableHeader`"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>$(Escape-Xml $Headers[$i])</w:t></w:r></w:p></w:tc>"
    }
    $xml += "</w:tr>"
    foreach ($row in $Rows) {
        $xml += "<w:tr>"
        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $xml += "<w:tc><w:tcPr><w:tcW w:w=`"$($Widths[$i])`" w:type=`"dxa`"/></w:tcPr><w:p><w:pPr><w:pStyle w:val=`"TableText`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$(Escape-Xml ([string]$row[$i]))</w:t></w:r></w:p></w:tc>"
        }
        $xml += "</w:tr>"
    }
    $xml += "</w:tbl><w:p/>"
    $body.Add($xml)
}

function Add-CodeBlock {
    param([string[]]$Lines)
    foreach ($line in $Lines) {
        $body.Add("<w:p><w:pPr><w:pStyle w:val=`"CodeBlock`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$(Escape-Xml $line)</w:t></w:r></w:p>")
    }
}

Add-Paragraph "Spotify Clone Web Music Player" "Title"
Add-Paragraph "Professional Project Report" "Subtitle"
Add-Paragraph "Prepared for GitHub Repository, Portfolio Showcase, Internship Applications, Resume Project Section, and Technical Submission" "Subtitle"
Add-Paragraph "Developer: Om" "Normal" $true
Add-Paragraph "Technology Stack: HTML5, CSS3, JavaScript, Fetch API, JSON, Browser Audio API" "Normal"
Add-Paragraph "Project Path: projects/Spotify clone H" "Normal"
Add-Paragraph "Report Date: June 5, 2026" "Normal"
Add-PageBreak

Add-Heading "Abstract" 1
Add-Paragraph "This report documents a Spotify-inspired web music player developed using HTML, CSS, and vanilla JavaScript. The application demonstrates dynamic playlist loading, dynamic album card generation, browser-based audio playback, seekbar interaction, volume management, keyboard shortcuts, and responsive mobile navigation. The project is a strong frontend learning artifact because it combines static interface design with runtime data loading and event-driven user interaction."
Add-Paragraph "The system organizes audio content through folder-based playlists. Each playlist folder contains MP3 files, a cover image, and an info.json metadata file. JavaScript reads this structure, renders albums and songs dynamically, and connects user actions to the browser Audio API."

Add-Heading "Introduction" 1
Add-Paragraph "Music streaming applications are useful examples for learning modern frontend development because they combine layout design, media control, dynamic rendering, and user interaction. This project recreates the core behavior of a Spotify-style web player in a lightweight client-side application."
Add-Paragraph "The project uses a left sidebar for navigation and song listings, a main content panel for album cards, and a bottom playback bar for audio controls. It does not rely on frameworks, which makes the implementation useful for understanding raw DOM manipulation, asynchronous loading, and browser media APIs."

Add-Heading "Problem Statement" 1
Add-Paragraph "The goal of the project was to build a responsive music player that can load songs dynamically, display playlist cards, and allow the user to control playback through a familiar Spotify-inspired interface. The solution needed to support playlist switching, song selection, play/pause behavior, previous and next navigation, seekbar control, volume control, mute/unmute, and mobile sidebar behavior."

Add-Heading "Objectives" 1
Add-Bullet "Design a Spotify-inspired web player interface using semantic HTML and structured CSS."
Add-Bullet "Implement dynamic song loading from local playlist folders."
Add-Bullet "Render album cards dynamically using folder metadata from JSON files."
Add-Bullet "Use the browser Audio API for playback control."
Add-Bullet "Implement responsive behavior for desktop, tablet, and mobile screen sizes."
Add-Bullet "Add user experience enhancements such as keyboard shortcuts, hover states, and draggable seekbar control."
Add-PageBreak

Add-Heading "Project Structure" 1
Add-CodeBlock @(
"Spotify clone H/",
"|-- index.html",
"|-- script.js",
"|-- Refactored.css",
"|-- style.css",
"|-- utility.css",
"|-- favicon.ico",
"|-- img/",
"|   |-- logo.svg",
"|   |-- play.svg",
"|   |-- pause.svg",
"|   |-- playbutton.svg",
"|   |-- previous.svg",
"|   |-- forward.svg",
"|   |-- volume.svg",
"|   |-- mute.svg",
"|   |-- hamburger.svg",
"|   |-- close.svg",
"|   `-- other interface icons",
"`-- songs/",
"    |-- cs/",
"    |-- ncs/",
"    |-- Finding Her/",
"    |-- Ashique 2/",
"    `-- Ye jawaani hai deewani/"
)
Add-Paragraph "The root folder contains the active application files. The img folder stores SVG interface icons. The songs folder stores folder-based playlists, where each playlist contains audio files, cover.jpg, and info.json. The active stylesheet is Refactored.css, while style.css appears to be an earlier stylesheet retained in the project."

Add-Heading "File Purpose Summary" 2
Add-Table @("File or Folder", "Purpose") @(
    @("index.html", "Defines the application layout, sidebar, album area, playbar, controls, and script/style links."),
    @("script.js", "Contains playlist loading, album rendering, Audio API control, event listeners, seekbar logic, and responsive sidebar logic."),
    @("Refactored.css", "Active stylesheet with variables, layout rules, responsive media queries, card styling, and playbar styling."),
    @("utility.css", "Reusable utility classes for flex, colors, border radius, inverted icons, and scrollbar styling."),
    @("style.css", "Previous or alternate stylesheet version kept in the repository."),
    @("img/", "Stores SVG icons used throughout the interface."),
    @("songs/", "Stores album folders, metadata, cover images, and MP3 audio files.")
) @(2300,7060)
Add-PageBreak

Add-Heading "Technologies Used" 1
Add-Table @("Technology", "Use in Project") @(
    @("HTML5", "Creates the application structure including sidebar, header, album cards, and playback bar."),
    @("CSS3", "Controls visual styling, spacing, colors, animations, and responsive layouts."),
    @("JavaScript", "Implements dynamic rendering, event handling, playback logic, and state management."),
    @("Fetch API", "Loads local folder listings and playlist metadata."),
    @("Async/Await", "Keeps asynchronous playlist and album loading readable."),
    @("JSON", "Stores album title and description in info.json files."),
    @("Browser Audio API", "Controls audio playback, duration, current time, pause/play state, and volume."),
    @("CSS Grid", "Creates responsive album card grids and playbar layout."),
    @("Flexbox", "Aligns sidebar sections, header controls, song rows, footer links, and playback controls.")
) @(2300,7060)

Add-Heading "System Design" 1
Add-Paragraph "The system is organized into five layers: presentation, styling, behavior, media assets, and playlist data. The presentation layer is defined in index.html. The styling layer is handled by Refactored.css and utility.css. The behavior layer is implemented in script.js. The media layer consists of SVG icons, cover images, and MP3 files. The playlist data layer is represented by song folders and info.json files."
Add-Paragraph "This separation allows the interface to remain stable while JavaScript dynamically replaces album cards and song lists based on available folders."

Add-Heading "Application Flow" 2
Add-Number "The browser loads index.html."
Add-Number "The page imports Refactored.css, utility.css, and script.js."
Add-Number "main() runs as the JavaScript entry point."
Add-Number "getSongs('songs/cs') loads the default playlist."
Add-Number "playMusic(firstSong, true) prepares the first track without autoplay."
Add-Number "displayAlbums() scans the songs folder and renders album cards."
Add-Number "User actions trigger playback, playlist switching, seeking, volume changes, and UI updates."
Add-PageBreak

Add-Heading "HTML Structure Analysis" 1
Add-Paragraph "The HTML document uses a two-column application layout. The .left section works as the sidebar and includes the Spotify logo, basic navigation, library list, and footer links. The .right section contains the top header, album card area, and fixed bottom playbar."
Add-Paragraph "The song library uses an empty unordered list that JavaScript fills dynamically. The album cards initially exist in the HTML, but displayAlbums() clears the card container and regenerates cards from the folders inside songs/. This means the final rendered cards come from runtime data rather than hardcoded markup."
Add-Paragraph "The playbar includes the seekbar, draggable circle, song information display, playback controls, volume icon, range input, and song time display. These elements are selected by JavaScript and updated during user interaction."

Add-Heading "CSS Architecture Analysis" 1
Add-Paragraph "Refactored.css is the active stylesheet. It uses a :root token system for colors, spacing, radii, transitions, sidebar width, and playbar height. This improves maintainability because repeated values are centralized."
Add-Paragraph "The layout combines Flexbox and CSS Grid. Flexbox is used for the main layout, sidebar organization, header, controls, footer, and volume area. CSS Grid is used for album cards and the playbar's three-column arrangement. Multiple media queries adapt the interface for smaller screens."
Add-Paragraph "The design includes Spotify-like dark surfaces, green play buttons, hover states, icon inversion, hidden scrollbars, responsive cards, and a mobile drawer sidebar."

Add-Heading "JavaScript Architecture Analysis" 1
Add-Paragraph "The JavaScript file uses a simple state model. The songs array stores the active playlist, currFolder stores the active folder path, and currentSong is a single Audio object used for playback. Functions are responsible for formatting time, loading songs, playing audio, displaying albums, and initializing the application."
Add-Paragraph "Most behavior is event-driven. Click handlers operate playback controls, playlist cards, song rows, seekbar, volume icon, hamburger menu, and close button. Keyboard handlers add spacebar play/pause and arrow-key navigation."
Add-PageBreak

Add-Heading "Feature Documentation" 1
Add-Heading "Dynamic Playlist Loading" 2
Add-Paragraph "The getSongs(folder) function fetches a folder listing, extracts links ending in .mp3, stores them in the songs array, and renders each track in the sidebar library. Clicking a song row calls playMusic() with the matching song URL."
Add-Heading "Dynamic Album Cards" 2
Add-Paragraph "The displayAlbums() function fetches the songs directory, identifies album folders, loads each folder's info.json metadata, and generates cards with cover.jpg, title, and description. This makes new albums easy to add by creating a new folder with the required files."
Add-Heading "Playback Controls" 2
Add-Paragraph "Playback is controlled through the currentSong Audio object. The play button toggles between play and pause, the previous button plays the previous song in the current playlist, and the next button plays the following song if it exists."
Add-Heading "Seekbar and Time Display" 2
Add-Paragraph "The timeupdate event updates both the text time display and the position of the seekbar circle. Clicking the seekbar calculates the clicked percentage and updates currentSong.currentTime. Dragging the circle continuously updates playback position."
Add-Heading "Volume and Mute" 2
Add-Paragraph "The range input controls volume by dividing the slider value by 100. The volume icon toggles between muted and unmuted states and switches between volume.svg and mute.svg."
Add-Heading "Responsive Mobile Sidebar" 2
Add-Paragraph "At mobile breakpoints, the sidebar becomes a fixed off-canvas panel. The hamburger icon sets the sidebar left position to 0, while the close icon moves it back to -100%."
Add-PageBreak

Add-Heading "Function Documentation" 1
Add-Table @("Function", "Purpose", "Key Dependencies") @(
    @("formatTime(seconds)", "Converts seconds into MM:SS format and returns 00:00 for invalid durations.", "Math.floor, String.padStart"),
    @("getSongs(folder)", "Fetches MP3 files from a playlist folder, renders the song library, and attaches song click events.", "fetch, DOM, songs array, playMusic"),
    @("playMusic(track, pause)", "Loads a track into the Audio object, optionally starts playback, and updates song info/time UI.", "currentSong, play icon, .songinfo, .songtime"),
    @("displayAlbums()", "Fetches album folders, reads info.json metadata, and renders dynamic album cards.", "fetch, JSON, .cardContainer"),
    @("main()", "Initializes the app, loads default songs, displays albums, and registers all event listeners.", "getSongs, displayAlbums, playMusic, Audio API"),
    @("togglePlay()", "Toggles the active Audio object between play and pause states.", "currentSong, play icon"),
    @("playPreviousSong()", "Finds the active song index and plays the previous track when available.", "songs, currentSong.src, playMusic"),
    @("playNextSong()", "Finds the active song index and plays the next track when available.", "songs, currentSong.src, playMusic")
) @(2300,4300,2760)

Add-Heading "Event Handling Summary" 2
Add-Bullet "Song list click events call playMusic() for the selected song."
Add-Bullet "The play icon click event toggles play and pause."
Add-Bullet "The Space key toggles playback while preventing page scroll."
Add-Bullet "The ArrowLeft and ArrowRight keys call previous and next song handlers."
Add-Bullet "The audio timeupdate event refreshes duration text and seekbar progress."
Add-Bullet "Seekbar click and drag events update the current playback position."
Add-Bullet "Volume input events update currentSong.volume."
Add-Bullet "Playlist card click events load a different song folder."
Add-PageBreak

Add-Heading "Song Management System" 1
Add-Paragraph "The project uses a folder-based content management approach. Each album folder represents a playlist and contains audio files, cover artwork, and metadata. This design is simple and suitable for a static frontend project because it avoids backend complexity while still demonstrating dynamic behavior."
Add-Table @("Playlist Folder", "Metadata Title", "Description") @(
    @("songs/cs", "copyright songs", "songs you like the most"),
    @("songs/ncs", "No copyright songs", "songs you like the most"),
    @("songs/Finding Her", "Finding Her", "Kushragra,saaheal"),
    @("songs/Ashique 2", "Aashiqui 2", "Mitthon, Ankit Tiwari, Jeet Ganguli"),
    @("songs/Ye jawaani hai deewani", "Ye jawaani hai deewani", "Pritam")
) @(2600,2800,3960)

Add-Heading "Dynamic Metadata Loading" 2
Add-Paragraph "The info.json files provide album titles and descriptions. displayAlbums() fetches these files individually and uses the returned JSON object to build each card. The cover image is loaded from the same folder using the standard filename cover.jpg."

Add-Heading "Audio Player Logic" 1
Add-Paragraph "The app creates one Audio object with new Audio(). This object persists across the application and changes source whenever the user selects a new track. Centralizing playback in one object makes it easier to keep controls, time display, seekbar, and volume connected to the active song."
Add-Paragraph "The playMusic() function is the key bridge between playlist data and player behavior. It receives a track URL, assigns it to currentSong.src, starts playback unless pause is set to true, updates the play icon, and displays the decoded song name in the playbar."
Add-PageBreak

Add-Heading "Code Quality Review" 1
Add-Heading "Strengths" 2
Add-Bullet "The project demonstrates real frontend interactivity rather than only static layout."
Add-Bullet "The folder-based playlist system makes the project easy to extend."
Add-Bullet "The Audio API implementation covers common player controls."
Add-Bullet "The responsive CSS has improved structure and practical breakpoints."
Add-Bullet "Keyboard shortcuts and draggable seekbar provide a stronger user experience."

Add-Heading "Weaknesses" 2
Add-Bullet "getSongs() contains a hardcoded localhost URL, which reduces portability."
Add-Bullet "The app depends on local directory listings, which may not work on all hosting platforms."
Add-Bullet "Some text and comments contain spelling mistakes such as libarary and listiner."
Add-Bullet "The app has limited error handling when fetch requests fail."
Add-Bullet "There is no automatic next-song behavior when a track ends."
Add-Bullet "The volume icon unmute behavior sets the slider to 10 while audio volume is set to 1."

Add-Heading "Refactoring Suggestions" 2
Add-Bullet "Replace directory-listing parsing with a songs.json manifest for deployment reliability."
Add-Bullet "Move repeated DOM queries into cached constants."
Add-Bullet "Render song list items using createElement or DocumentFragment instead of repeated innerHTML concatenation."
Add-Bullet "Create a central player state object for current playlist, current index, volume, and playback status."
Add-Bullet "Remove unused or duplicate files such as img/index.html if they are not needed."

Add-Heading "Accessibility Suggestions" 2
Add-Bullet "Use buttons for playback controls instead of clickable images."
Add-Bullet "Add aria-label values for play, pause, next, previous, mute, hamburger, and close controls."
Add-Bullet "Add meaningful alt text to album covers."
Add-Bullet "Make the seekbar keyboard-accessible."
Add-Bullet "Improve visible focus styles for keyboard users."
Add-PageBreak

Add-Heading "Testing Strategy" 1
Add-Paragraph "The project should be tested manually across desktop and mobile screen sizes. Because the app depends on browser media behavior and local file serving, manual testing is important for verifying actual playback and interaction quality."
Add-Table @("Test Area", "Expected Result") @(
    @("Initial Load", "Default playlist loads and the first song name appears without autoplay."),
    @("Album Card Click", "Sidebar library updates with songs from the selected folder."),
    @("Song Click", "Selected song starts playing and the play icon changes to pause."),
    @("Play/Pause", "Button and Space key toggle audio playback correctly."),
    @("Previous/Next", "Buttons and arrow keys switch tracks within playlist bounds."),
    @("Seekbar Click", "Playback jumps to the selected position."),
    @("Seekbar Drag", "Circle moves smoothly and updates currentSong.currentTime."),
    @("Volume Slider", "Audio volume changes according to slider value."),
    @("Mute Icon", "Audio mutes and icon changes to mute.svg."),
    @("Mobile Sidebar", "Hamburger opens sidebar and close icon hides it.")
) @(2500,6860)

Add-Heading "Challenges Faced" 1
Add-Bullet "Building dynamic playlist behavior without a backend server."
Add-Bullet "Synchronizing audio playback state with visual UI controls."
Add-Bullet "Calculating seekbar position from click and drag events."
Add-Bullet "Designing a responsive layout that preserves player usability on small screens."
Add-Bullet "Managing folders with spaces and URL-encoded song names."

Add-Heading "Solutions Implemented" 1
Add-Bullet "Used Fetch API to load folder listings and JSON metadata."
Add-Bullet "Used decodeURIComponent to display cleaner song names."
Add-Bullet "Used currentSong.currentTime and currentSong.duration for seekbar calculations."
Add-Bullet "Used CSS Grid and media queries for responsive album card layout."
Add-Bullet "Used an off-canvas sidebar pattern for mobile screens."
Add-PageBreak

Add-Heading "Future Scope" 1
Add-Bullet "Add search functionality for albums and songs."
Add-Bullet "Add shuffle and repeat controls."
Add-Bullet "Auto-play the next song when the current track ends."
Add-Bullet "Highlight the currently playing song in the sidebar."
Add-Bullet "Persist volume and last-played song using localStorage."
Add-Bullet "Replace folder parsing with a production-ready manifest file."
Add-Bullet "Add loading states and user-facing error messages."
Add-Bullet "Improve accessibility and keyboard navigation."
Add-Bullet "Deploy the app with optimized assets and compressed media."

Add-Heading "Learning Outcomes" 1
Add-Paragraph "This project demonstrates practical understanding of DOM manipulation, event-driven programming, asynchronous JavaScript, JSON metadata, responsive interface design, and the browser Audio API. It also shows the ability to organize assets, structure a frontend project, and create a user-facing application with real interactive behavior."
Add-Paragraph "For portfolio and internship purposes, the most valuable aspect of this project is that it goes beyond static design. It includes dynamic content loading, runtime rendering, media control, state updates, and responsive interaction patterns."

Add-Heading "Conclusion" 1
Add-Paragraph "The Spotify Clone project successfully implements the core experience of a web music player using foundational web technologies. The application includes dynamic playlists, album cards, playback controls, seekbar interaction, volume management, keyboard shortcuts, and mobile responsiveness. With improvements such as a manifest-based data source, stronger accessibility, and production-ready deployment handling, the project can become an even stronger portfolio showcase."
Add-PageBreak

Add-Heading "Appendix A: README Content" 1
Add-Paragraph "Project Name: Spotify Clone"
Add-Paragraph "Overview: A responsive Spotify-inspired web music player built using HTML, CSS, and JavaScript. The project supports dynamic playlist loading, album card generation, audio playback controls, seekbar interaction, volume control, keyboard shortcuts, and mobile sidebar navigation."
Add-Paragraph "Features: dynamic playlist loading, dynamic album cards, play/pause, previous/next, song switching, seekbar, draggable progress circle, volume slider, mute toggle, keyboard shortcuts, responsive layout, and mobile sidebar."
Add-Paragraph "Installation: Clone or download the repository and run index.html through a local development server such as VS Code Live Server."
Add-Paragraph "Future Improvements: search, shuffle, repeat, auto-play next, current track highlighting, production manifest, accessibility improvements, and deployment optimization."

Add-Heading "Appendix B: Resume Descriptions" 1
Add-Paragraph "One-line resume description: Built a responsive Spotify-inspired music player using HTML, CSS, and JavaScript with dynamic playlists, audio controls, seekbar, volume control, and keyboard shortcuts."
Add-Paragraph "Two-line resume description: Developed a Spotify Clone web application using vanilla JavaScript, HTML, and CSS. Implemented dynamic album rendering, folder-based song loading, Audio API playback, responsive UI, seekbar dragging, volume control, and keyboard navigation."
Add-Paragraph "Internship project description: Created a fully functional Spotify-inspired frontend music player that dynamically loads albums and songs from structured folders using Fetch API and JSON metadata. Implemented core playback features including play, pause, previous, next, seekbar, volume, mute, keyboard shortcuts, and mobile sidebar navigation using vanilla JavaScript and responsive CSS."

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" mc:Ignorable="w14 w15 wp14">
<w:body>
$($body -join "`n")
<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/><w:cols w:space="720"/><w:docGrid w:linePitch="360"/></w:sectPr>
</w:body>
</w:document>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/><w:color w:val="111827"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="264" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="120" w:line="264" w:lineRule="auto"/></w:pPr><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/><w:color w:val="111827"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="720" w:after="120"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:sz w:val="52"/><w:color w:val="0B2545"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="160"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="26"/><w:color w:val="4B5563"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="320" w:after="160"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="2E74B5"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:sz w:val="26"/><w:color w:val="2E74B5"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="160" w:after="80"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:sz w:val="24"/><w:color w:val="1F4D78"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="ListParagraph"><w:name w:val="List Paragraph"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="120" w:line="280" w:lineRule="auto"/><w:ind w:left="720" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="CodeBlock"><w:name w:val="Code Block"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="20"/><w:shd w:val="clear" w:fill="F8FAFC"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="19"/><w:color w:val="111827"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TableHeader"><w:name w:val="Table Header"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:sz w:val="20"/><w:color w:val="0B2545"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TableText"><w:name w:val="Table Text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="20"/><w:color w:val="111827"/></w:rPr></w:style>
</w:styles>
"@

$numberingXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:abstractNum w:abstractNumId="1"><w:multiLevelType w:val="singleLevel"/><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="•"/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="720"/></w:tabs><w:ind w:left="720" w:hanging="360"/></w:pPr><w:rPr><w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/></w:rPr></w:lvl></w:abstractNum>
<w:abstractNum w:abstractNumId="2"><w:multiLevelType w:val="singleLevel"/><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="720"/></w:tabs><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum>
<w:num w:numId="1"><w:abstractNumId w:val="1"/></w:num>
<w:num w:numId="2"><w:abstractNumId w:val="2"/></w:num>
</w:numbering>
"@

$contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
<Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>
<Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
"@

$rels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@

$docRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>
<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
</Relationships>
"@

$settings = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:zoom w:percent="100"/><w:defaultTabStop w:val="720"/></w:settings>
"@

$created = (Get-Date).ToUniversalTime().ToString("s") + "Z"
$core = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<dc:title>Spotify Clone Web Music Player Project Report</dc:title>
<dc:creator>Om</dc:creator>
<cp:lastModifiedBy>Codex</cp:lastModifiedBy>
<dcterms:created xsi:type="dcterms:W3CDTF">$created</dcterms:created>
<dcterms:modified xsi:type="dcterms:W3CDTF">$created</dcterms:modified>
</cp:coreProperties>
"@

$app = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"><Application>Codex OOXML Builder</Application><DocSecurity>0</DocSecurity><ScaleCrop>false</ScaleCrop><Company></Company><LinksUpToDate>false</LinksUpToDate><SharedDoc>false</SharedDoc><HyperlinksChanged>false</HyperlinksChanged><AppVersion>16.0000</AppVersion></Properties>
"@

Set-Content -LiteralPath (Join-Path $buildDir "[Content_Types].xml") -Value $contentTypes -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "_rels\.rels") -Value $rels -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "word\document.xml") -Value $documentXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "word\styles.xml") -Value $stylesXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "word\numbering.xml") -Value $numberingXml -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "word\settings.xml") -Value $settings -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "word\_rels\document.xml.rels") -Value $docRels -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "docProps\core.xml") -Value $core -Encoding UTF8
Set-Content -LiteralPath (Join-Path $buildDir "docProps\app.xml") -Value $app -Encoding UTF8

$zipPath = Join-Path $projectRoot ("Spotify_Clone_Project_Report_" + [System.Guid]::NewGuid().ToString("N") + ".zip")
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
$archive = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    Get-ChildItem -LiteralPath $buildDir -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($buildDir.Length + 1).Replace("\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $relative) | Out-Null
    }
} finally {
    $archive.Dispose()
}
[System.IO.File]::Copy($zipPath, $outFile, $true)
try {
    Remove-Item -LiteralPath $zipPath -Force
} catch {
    Write-Warning "Temporary ZIP cleanup skipped: $($_.Exception.Message)"
}

Write-Output $outFile
