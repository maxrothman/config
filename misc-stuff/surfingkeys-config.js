// settings.smoothScroll = false
settings.scrollStepSize = 90
chrome.storage.local.set({"noPdfViewer": 1})
api.unmapAllExcept(['f'], /.*/)
// api.map('e', '<Alt-up>')
// api.map('d', '<Alt-down>')
// api.map('j', '<Up>')
// api.map('k', '<Down>')
// There appears to be no way to map the arrow keys: https://github.com/brookhong/Surfingkeys/issues/1766
// Long term: possibly extract the hints and scroll bits to new extensions? This thing sucks

api.Hints.style("font-family: Helvetica, sans-serif;")
settings.hintShiftNonActive = true

// TODO: use https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md#hintscreate to make hints for scrollable areas

// // an example to create a new mapping `ctrl-y`
// api.mapkey('<ctrl-y>', 'Show me the money', function() {
//     Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
// });

// // an example to replace `T` with `gt`, click `Default mappings` to see how `T` works.
// api.map('gt', 'T');

// // an example to remove mapkey `Ctrl-i`
// api.unmap('<ctrl-i>');

// // set theme
// settings.theme = `
// .sk_theme {
//     font-family: Input Sans Condensed, Charcoal, sans-serif;
//     font-size: 10pt;
//     background: #24272e;
//     color: #abb2bf;
// }
// .sk_theme tbody {
//     color: #fff;
// }
// .sk_theme input {
//     color: #d0d0d0;
// }
// .sk_theme .url {
//     color: #61afef;
// }
// .sk_theme .annotation {
//     color: #56b6c2;
// }
// .sk_theme .omnibar_highlight {
//     color: #528bff;
// }
// .sk_theme .omnibar_timestamp {
//     color: #e5c07b;
// }
// .sk_theme .omnibar_visitcount {
//     color: #98c379;
// }
// .sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
//     background: #303030;
// }
// .sk_theme #sk_omnibarSearchResult ul li.focused {
//     background: #3e4452;
// }
// #sk_status, #sk_find {
//     font-size: 20pt;
// }`;
// // click `Save` button to make above settings to take effect.</ctrl-i></ctrl-y>

// console.log('hi hi')
