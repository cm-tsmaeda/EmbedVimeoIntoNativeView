function getParameterByName(name) {
    const match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}

function fetchVideoInfo(id) {
    const videoUrl = "https://vimeo.com/" + id;
    const encoded = encodeURIComponent(videoUrl);
    const fetchUrl = "https://vimeo.com/api/oembed.json?responsive=true&url=" + encoded;
    fetch(fetchUrl)
        .then(function(response) {
            if (!response.ok) {
                throw new Error("HTTP Error!");
            }
            return response.json();
        })
        .then(function(response) {
            //console.log(response);
            embedVideo(response.html);
        });
}

function embedVideo(htmlStr) {
    const body = document.getElementsByTagName('body')[0];
    body.insertAdjacentHTML('afterbegin', htmlStr);
    //console.log('embed', htmlStr);
}

const videoId = getParameterByName('id');
fetchVideoInfo(videoId);
