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
    $( ".lde-js-play" ).addClass( "d-none" );
    $( ".lde-js-stop" ).removeClass( "d-none" );
  } else {
    $( ".lde-js-play" ).removeClass( "d-none" );
    $( ".lde-js-stop" ).addClass( "d-none" );
  }
});

// reached end of track
wavesurfer.on('finish', function () {
  wavesurfer.stop();
  // calculate repeat and adjust play button
  if ( loopStatus ) {
    wavesurfer.play();
    $( ".lde-js-play" ).addClass( "d-none" );
    $( ".lde-js-stop" ).removeClass( "d-none" );
  } else {
    $( ".lde-js-play" ).removeClass( "d-none" );
    $( ".lde-js-stop" ).addClass( "d-none" );
  }
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
    if ( wavesurfer.isPlaying() ) {
      $( ".lde-js-play" ).addClass( "d-none" );
      $( ".lde-js-stop" ).removeClass( "d-none" );
    } else {
      $( ".lde-js-play" ).removeClass( "d-none" );
      $( ".lde-js-stop" ).addClass( "d-none" );
    }
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

  // bind function play track (from track list)
  $( ".lde-js-play-track" ).on( "click", function( event ) {
    event.stopPropagation();
    // load track to player
    loadTrack( $(this).attr('href'), $(this).data('prerendered-json') );
    $("#waveform .spinner-border").show();
    $("#waveform .lde-message").show();
    $(".lde-current-track-name").html( $(this).data('track-name') );
    playAfterLoading = true;
    $("html, body").animate({ scrollTop: $(".lde-player").offset().top - 100 }, 1000);
    return false;
  });

  // add function to change tab (disk sides)
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    //e.target // newly activated tab
    //e.relatedTarget // previous active tab
    $( ".lde-currend-side-cover" ).addClass("d-none");
    console.log( "." + $( this ).data('side-cover') );
    $( "." + $( this ).data('side-cover') ).removeClass("d-none");
  })


});

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