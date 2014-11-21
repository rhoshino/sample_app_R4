function updateCountdown(){
    //140 charactors max

    var $countdown = $('.countdown');

    // 140 is the max message length
    var remaining = 140 - $('#micropost_content').val().length;

    $countdown.text(remaining + ' characters remaining');

    var color = 'grey';
    if (remaining < 21) { color = 'black'; }
    if (remaining < 11) { color = 'red'; }
    $countdown.css( { color: color} );
}

$(document).ready(function($) {
    updateCountdown();
    $micropost_content = $('#micropost_content');

    $micropost_content.change(updateCountdown);
    $micropost_content.keyup(updateCountdown);
    $micropost_content.keydown(updateCountdown);
});