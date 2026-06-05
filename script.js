console.log("lets write javascript");
let songs;
let currFolder;
function formatTime(seconds) {
  if (isNaN(seconds)) return "00:00";

  let mins = Math.floor(seconds / 60);
  let secs = Math.floor(seconds % 60);

  // 2 digit format (05, 09, etc.)
  mins = String(mins).padStart(2, "0");
  secs = String(secs).padStart(2, "0");

  return `${mins}:${secs}`;
}
async function getSongs(folder) {
  currFolder = folder;

  try {
    let res = await fetch(`songs/${folder}/songs.json`);

    if (!res.ok) {
      console.error(
        `songs.json not found for folder "${folder}" (status ${res.status})`,
      );
      return [];
    }

    let songNames = await res.json();
    if (!Array.isArray(songNames)) {
      console.error(
        `songs.json for folder "${folder}" does not contain an array`,
      );
      return [];
    }

    songs = songNames.map((song) => `songs/${folder}/${song}`);

    // render library
    let songUL = document.querySelector(".song-Library ul");

    songUL.innerHTML = "";

    for (const song of songs) {
      let name = decodeURIComponent(song.split("/").pop()).replace(".mp3", "");

      songUL.innerHTML += `
      <li>
        <img class="invert music-icon" src="img/music.svg">
        <div class="info">
          <div>${name}</div>
          <div>Om</div>
        </div>
        <div class="playnow">
          <img class="invert" src="img/playbutton.svg">
        </div>
      </li>`;
    }

    Array.from(songUL.getElementsByTagName("li")).forEach((e, index) => {
      e.addEventListener("click", () => {
        playMusic(songs[index]);
      });
    });

    return songs;
  } catch (err) {
    console.error(err);
    return [];
  }
}

// async function getSongs(folder) {
//   currFolder = folder;
//   try {
//     let a = await fetch(`songs/${folder}/songs.json`);
//     if (!a.ok) {
//       console.error(`Failed to load folder: ${folder}`, a.status);
//       songs = [];
//       return songs;
//     }
//     let response = await a.text();
//     let div = document.createElement("div");
//     div.innerHTML = response;
//     let as = div.getElementsByTagName("a");
//     songs = [];
//     for (let index = 0; index < as.length; index++) {
//       const element = as[index];
//       if (element.href.endsWith(".mp3")) {
//         songs.push(element.href);
//       }
//     }
//   } catch (error) {
//     console.error("Error fetching songs:", error);
//     songs = [];
//     return songs;
//   }
//   // showing all the songs in the playlist by useing split by"/" and poping the last name
//   let songUL = document
//     .querySelector(".song-Library")
//     .getElementsByTagName("ul")[0];
//   songUL.innerHTML = "";
//   for (const song of songs) {
//     let name = song.split("/").pop();
//     name = decodeURIComponent(name);
//     name = name.replace(".mp3", "");
//     songUL.innerHTML += `<li>
//                 <img class="invert music-icon" src="img/music.svg" alt="" />
//                 <div class="info">
//                   <div>${name}</div>
//                   <div>Om</div>
//                 </div>
//                 <div class="playnow">
//                   <img class="invert" src="img/playbutton.svg" alt="" />
//                 </div>
//     </li>`;
//   }

//   // Attach Event listiner to every song.
//   Array.from(
//     document.querySelector(".song-Library").getElementsByTagName("li"),
//   ).forEach((e, index) => {
//     e.addEventListener("click", (element) => {
//       console.log(e.querySelector(".info").firstElementChild.innerHTML);
//       playMusic(songs[index]);
//     });
//   });
//   return songs;
// }
let play = document.querySelector(".play-icon");
let currentSong = new Audio();
const playMusic = (track, pause = false) => {
  if (!track) {
    console.warn("No track provided to playMusic");
    return;
  }

  currentSong.src = track;
  if (!pause) {
    // Handle play promise rejection (AbortError)
    const playPromise = currentSong.play();
    if (playPromise !== undefined) {
      playPromise.catch((error) => {
        console.log("Play interrupted:", error);
      });
    }
    play.src = "img/pause.svg";
  }

  document.querySelector(".songinfo").innerHTML = decodeURIComponent(
    track.split("/").pop(),
  ).replace(".mp3", "");
  document.querySelector(".songtime").innerHTML = "00:00/00:00";
};

// display function for albums
async function displayAlbums() {
  try {
    let response = await fetch("songs/manifest.json");
    if (!response.ok) {
      console.error("Could not load manifest:", response.status);
      return;
    }

    let manifest = await response.json();
    let cardContainer = document.querySelector(".cardContainer");
    cardContainer.innerHTML = "";

    for (const album of manifest.albums) {
      cardContainer.innerHTML += ` <div data-folder="${album.folder}" class="card">
              <div class="card-image">
                <img
                  src="songs/${album.folder}/cover.jpg"
                  alt=""
                />
                <div class="play">
                  <img src="img/play.svg" alt="" />
                </div>
              </div>
              <h3>${album.title}</h3>
              <p>${album.description}</p>
            </div>`;
    }
  } catch (error) {
    console.error("Error loading albums:", error);
  }
}

async function main() {
  // Load first album by default
  let defaultAlbum = "ncs";
  songs = await getSongs(defaultAlbum);

  // Only play music if songs were found
  if (songs && songs.length > 0) {
    playMusic(songs[0], true);
  } else {
    console.warn("No songs found in the specified folder");
  }

  //Display all the albums
  await displayAlbums();

  //  Attach an event listener to play, next and previous

  const togglePlay = () => {
    if (currentSong.paused) {
      currentSong.play();
      play.src = "img/pause.svg";
    } else {
      currentSong.pause();
      play.src = "img/playbutton.svg";
    }
  };

  play.addEventListener("click", togglePlay);

  document.addEventListener("keydown", (e) => {
    if (e.code === "Space") {
      e.preventDefault(); // space key ka default behavior (scrolling) ko rok do
      togglePlay();
    }
  });

  //  Listen fir time update event
  currentSong.addEventListener("timeupdate", () => {
    document.querySelector(".songtime").innerHTML =
      `${formatTime(currentSong.currentTime)}/${formatTime(currentSong.duration)}`;
    if (!isNaN(currentSong.duration)) {
      let percent = (currentSong.currentTime / currentSong.duration) * 100;

      if (percent > 100) percent = 100;

      document.querySelector(".circle").style.left = percent + "%";
    }
  });

  // add an event listener to seekbar
  document.querySelector(".seekbar").addEventListener("click", (e) => {
    // seekbar per clik karna hai.
    let percent = (e.offsetX / e.target.getBoundingClientRect().width) * 100; // seekbar per kitne percent andar click hua hai.
    document.querySelector(".circle").style.left = percent + "%"; //circle ko seekbar per kaha tak le kar jana hai
    currentSong.currentTime = (currentSong.duration * percent) / 100; // song ki current time jaha per circle hai waha per kar do.
  });

  // add an event listener to the circle for draging
  let seekbar = document.querySelector(".seekbar");
  let circle = document.querySelector(".circle");
  let isDragging = false;
  circle.addEventListener("mousedown", () => {
    // circle per mouse aa gaya to ab ye event lag gaya hai
    isDragging = true;
  });
  document.addEventListener("mouseup", () => {
    // circle se mouse hat gaya hai.
    isDragging = false;
  });
  document.addEventListener("mousemove", (e) => {
    // jaha per mouse hata hai waha per ye function laga do
    if (!isDragging) return;
    let rect = seekbar.getBoundingClientRect();
    let offsetX = e.clientX - rect.left;
    // boundary set karne ke liye
    if (offsetX < 0) offsetX = 0;
    if (offsetX > rect.width) offsetX = rect.width;

    let percent = (offsetX / rect.width) * 100;
    circle.style.left = percent + "%";

    // update song
    if (!isNaN(currentSong.duration)) {
      currentSong.currentTime = (currentSong.duration * percent) / 100;
    }
  });
  // add an event listener for hamburger
  document.querySelector(".hamburger").addEventListener("click", () => {
    document.querySelector(".left").style.left = "0";
  });
  // add an even listener to the close button
  document.querySelector(".close").addEventListener("click", () => {
    document.querySelector(".left").style.left = "-100%";
  });
  const getCurrentSongIndex = () => {
    let currentSrc = currentSong.src;
    return songs.findIndex((song) => currentSrc.endsWith(song));
  };

  const playPreviousSong = () => {
    let index = getCurrentSongIndex();
    if (index <= 0) return;
    playMusic(songs[index - 1]);
  };
  const playNextSong = () => {
    let index = getCurrentSongIndex();
    if (index < 0 || index + 1 >= songs.length) return;
    playMusic(songs[index + 1]);
  };
  let previous = document.querySelector(".previous");
  let forward = document.querySelector(".forward");
  previous.addEventListener("click", playPreviousSong);
  forward.addEventListener("click", playNextSong);
  document.addEventListener("keydown", (e) => {
    if (e.code === "ArrowLeft") {
      playPreviousSong();
    } else if (e.code === "ArrowRight") {
      playNextSong();
    }
  });

  // let previous = document.querySelector(".previous");
  // previous.addEventListener("click", () => {
  //   let index = songs.indexOf(currentSong.src);

  //   if (index - 1 >= 0) {
  //     playMusic(songs[index - 1]);
  //   }
  // });
  // let forward = document.querySelector(".forward");
  // forward.addEventListener("click", () => {
  //   let index = songs.indexOf(currentSong.src);

  //   if (index + 1 < songs.length) {
  //     playMusic(songs[index + 1]);
  //   }
  // });

  // add an event listener to the volume

  let volume = document.querySelector("#volume");
  let volumeIcon = document.querySelector(".volume-icon");
  volumeIcon.addEventListener("click", (e) => {
    if (e.target.src.includes("img/volume.svg")) {
      currentSong.volume = 0;
      volume.value = 0;
      volumeIcon.src = "img/mute.svg";
    } else {
      currentSong.volume = 1;
      volume.value = 10;
      volumeIcon.src = "img/volume.svg";
    }
  });
  volume.addEventListener("input", () => {
    currentSong.volume = volume.value / 100;
    if (volume.value == 0) {
      volumeIcon.src = "img/mute.svg";
    } else {
      volumeIcon.src = "img/volume.svg";
    }
  });
  //card per click karte hi card ka gana library me aa jaye.
  Array.from(document.getElementsByClassName("card")).forEach((e) => {
    e.addEventListener("click", async (item) => {
      let folder = item.currentTarget.dataset.folder;
      if (!folder) {
        return;
      }

      songs = await getSongs(folder);
    });
  });
}

main();
