/* ==== settings ============================================================ */

// init wave surfer
var wavesurfer = WaveSurfer.create({
  container: '#waveform',
  backend: 'MediaElement',
  barWidth: 2,
  barRadius: 0,
  barHeight: 2,
  height: 200,
  barGap: 10,
  waveColor: '#4d4d4d',
  progressColor: '#fd7f00',
  plugins: [
    WaveSurfer.timeline.create({
        container: "#wave-timeline"
    })
  ]
});

// flag for repeat button
var loopStatus = false;

// flag for auto play
var playAfterLoading = false;

/* ==== events ============================================================== */

// ready to play track, peaks calculated
wavesurfer.on('ready', function () {
  // remove loading info
  $("#waveform .spinner-border").hide();
  $("#waveform .lde-message").hide();
  // calculate autoplay and adjust play button
  if ( playAfterLoading ) {
    wavesurfer.play();
    playAfterLoading = false;
  }
  handlePlayButton();
});

// reached end of track
wavesurfer.on('finish', function () {
  wavesurfer.stop();
  // calculate repeat and adjust play button
  if ( loopStatus ) {
    wavesurfer.play();
  }
  handlePlayButton();
});

// track is loading (but not ready to play after progress reached 100)
wavesurfer.on('loading', function (event) {
  // adjust progress bar
  var progress = event;
  $(".progress-bar").css('width',progress+'%');
  $(".progress-bar").html(progress + '%');
  if ( progress == 100 ) {
    $(".progress").hide();
  }
});

/* ==== functions =========================================================== */

/* ---- document ready ------------------------------------------------------ */
$(function() {

  // load track to player
  loadTrack( $('.lde-current-track-name').data('ini-track'), $('.lde-current-track-name').data('prerendered-json') );

  // bind function to backward button
  $( ".lde-js-button-backward" ).on( "click", function( event ) {
    event.stopPropagation();
    wavesurfer.skipBackward();
    return false;
  });

    // bind function to play button
  $( ".lde-js-button-play" ).on( "click", function( event ) {
    event.stopPropagation();
    wavesurfer.playPause();
    handlePlayButton();
    return false;
  });

  // bind function to forward button
  $( ".lde-js-button-forward" ).on( "click", function( event ) {
    event.stopPropagation();
    wavesurfer.skipForward();
    return false;
  });

  // bind function to loop button
  $( ".lde-js-button-loop" ).on( "click", function( event ) {
    event.stopPropagation();
    if ( loopStatus ) {
      loopStatus = false;
      $( ".lde-js-loop" ).toggleClass('active');
    } else {
      loopStatus = true;
      $( ".lde-js-loop" ).toggleClass('active');
    }
    console.log( loopStatus );
    return false;
  });

  // bind function to mute button
  $( ".lde-js-button-mute" ).on( "click", function( event ) {
    event.stopPropagation();
    wavesurfer.toggleMute();
    if ( wavesurfer.getMute() ) {
      $( ".lde-js-loud" ).addClass( "d-none" );
      $( ".lde-js-mute" ).removeClass( "d-none" );
    } else {
      $( ".lde-js-loud" ).removeClass( "d-none" );
      $( ".lde-js-mute" ).addClass( "d-none" );
    }
    return false;
  });

  // bind function play/stop track (from track list)
  $( ".lde-js-play-track" ).on( "click", function( event ) {
    event.stopPropagation();
    // current loaded track
    if ( $(".lde-current-track-name").html() == $(this).data('track-name') ) {
      // is playing
      if ( wavesurfer.isPlaying() ) {
        //pause track
        wavesurfer.pause();
      } else {
        // start playing
        wavesurfer.play();
      }
      // update buttons
      handlePlayButton();
    } else {
      // load track to player
      loadTrack( $(this).attr('href'), $(this).data('prerendered-json') );
      $("#waveform .spinner-border").show();
      $("#waveform .lde-message").show();
      $(".lde-current-track-name").html( $(this).data('track-name') );
      playAfterLoading = true;
      //$("html, body").animate({ scrollTop: $(".lde-player").offset().top - 100 }, 1000);
    }
    return false;
  });

  // toggle cover
  $( ".lde-js-coverToggle" ).on( "click", function( event ) {
    event.stopPropagation();
    $( ".lde-currend-side-cover" ).toggleClass("d-none");
    return false;
  })
});

/* ---- handlePlayButton ---------------------------------------------------- */
function handlePlayButton() {
  $("a[data-track-name]").removeClass('active');
  if ( wavesurfer.isPlaying() ) {
    $( ".lde-js-play" ).addClass( "d-none" );
    $( ".lde-js-stop" ).removeClass( "d-none" );
    $("a[data-track-name = '" + $(".lde-current-track-name").html() + "']").addClass('active');
  } else {
    $( ".lde-js-play" ).removeClass( "d-none" );
    $( ".lde-js-stop" ).addClass( "d-none" );
  }

}

/* ---- load track ---------------------------------------------------------- */
function loadTrack( trackURL, peakURL ) {
  // get pre calculated peaks
  fetch( peakURL )
  .then(response => {
    if (!response.ok) {
      throw new Error("HTTP error " + response.status);
    }
    return response.json();
  })
  .then(peaks => {
    $(".progress").hide();
    // use prerendered peaks and play track
    return wavesurfer.load( trackURL, peaks.data );
  })
  .catch((e) => {
    console.error('error', e);
    // calculate peaks client sided and play track
    return wavesurfer.load( trackURL );
  });
}