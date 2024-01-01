"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getVimeoURLParams = exports.isYouTubeNoCookie = exports.getYouTubeParams = exports.paramsToObject = exports.param = void 0;
exports.param = function (obj) {
    return Object.keys(obj)
        .map(function (k) {
        return encodeURIComponent(k) + '=' + encodeURIComponent(obj[k]);
    })
        .join('&');
};
exports.paramsToObject = function (url) {
    var paramas = url
        .slice(1)
        .split('&')
        .map(function (p) { return p.split('='); })
        .reduce(function (obj, pair) {
        var _a = pair.map(decodeURIComponent), key = _a[0], value = _a[1];
        obj[key] = value;
        return obj;
    }, {});
    return paramas;
};
exports.getYouTubeParams = function (videoInfo, youTubePlayerParamsSettings) {
    if (!videoInfo.youtube)
        return '';
    var slideUrlParams = videoInfo.youtube[2]
        ? exports.paramsToObject(videoInfo.youtube[2])
        : '';
    // For youtube first params gets priority if duplicates found
    var defaultYouTubePlayerParams = {
        wmode: 'opaque',
        autoplay: 0,
        mute: 1,
        enablejsapi: 1,
    };
    var playerParamsSettings = youTubePlayerParamsSettings || {};
    var youTubePlayerParams = __assign(__assign(__assign({}, defaultYouTubePlayerParams), playerParamsSettings), slideUrlParams);
    var youTubeParams = "?" + exports.param(youTubePlayerParams);
    return youTubeParams;
};
exports.isYouTubeNoCookie = function (url) {
    return url.includes('youtube-nocookie.com');
};
exports.getVimeoURLParams = function (defaultParams, videoInfo) {
    if (!videoInfo || !videoInfo.vimeo)
        return '';
    var urlParams = videoInfo.vimeo[2] || '';
    var defaultPlayerParams = defaultParams && Object.keys(defaultParams).length !== 0
        ? '&' + exports.param(defaultParams)
        : '';
    // Support private video
    var urlWithHash = videoInfo.vimeo[0].split('/').pop() || '';
    var urlWithHashWithParams = urlWithHash.split('?')[0] || '';
    var hash = urlWithHashWithParams.split('#')[0];
    var isPrivate = videoInfo.vimeo[1] !== hash;
    if (isPrivate) {
        urlParams = urlParams.replace("/" + hash, '');
    }
    urlParams =
        urlParams[0] == '?' ? '&' + urlParams.slice(1) : urlParams || '';
    // For vimeo last params gets priority if duplicates found
    var vimeoPlayerParams = "?autoplay=0&muted=1" + (isPrivate ? "&h=" + hash : '') + defaultPlayerParams + urlParams;
    return vimeoPlayerParams;
};
//# sourceMappingURL=lg-video-utils.js.map