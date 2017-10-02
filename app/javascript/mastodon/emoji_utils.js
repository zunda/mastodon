// This code is largely borrowed from:
// https://github.com/missive/emoji-mart/blob/bbd4fbe/src/utils/index.js

import data from './emoji_data_light';

const COLONS_REGEX = /^(?:\:([^\:]+)\:)(?:\:skin-tone-(\d)\:)?$/;

function buildSearch(thisData) {
  const search = [];

  let addToSearch = (strings, split) => {
    if (!strings) {
      return;
    }

    (Array.isArray(strings) ? strings : [strings]).forEach((string) => {
      (split ? string.split(/[-|_|\s]+/) : [string]).forEach((s) => {
        s = s.toLowerCase();

        if (search.indexOf(s) === -1) {
          search.push(s);
        }
      });
    });
  };

  addToSearch(thisData.short_names, true);
  addToSearch(thisData.name, true);
  addToSearch(thisData.keywords, false);
  addToSearch(thisData.emoticons, false);

  return search;
}

function unifiedToNative(unified) {
  let unicodes = unified.split('-'),
    codePoints = unicodes.map((u) => `0x${u}`);

  return String.fromCodePoint(...codePoints);
}

function sanitize(emoji) {
  let { name, short_names, skin_tone, skin_variations, emoticons, unified, custom, imageUrl } = emoji,
    id = emoji.id || short_names[0],
    colons = `:${id}:`;

  if (custom) {
    return {
      id,
      name,
      colons,
      emoticons,
      custom,
      imageUrl,
    };
  }

  if (skin_tone) {
    colons += `:skin-tone-${skin_tone}:`;
  }

  return {
    id,
    name,
    colons,
    emoticons,
    unified: unified.toLowerCase(),
    skin: skin_tone || (skin_variations ? 1 : null),
    native: unifiedToNative(unified),
  };
}

function getSanitizedData(emoji) {
  return sanitize(getData(emoji));
}

function getData(emoji) {
  let emojiData = {};

  if (typeof emoji === 'string') {
    let matches = emoji.match(COLONS_REGEX);

    if (matches) {
      emoji = matches[1];

    }

    if (data.short_names.hasOwnProperty(emoji)) {
      emoji = data.short_names[emoji];
    }

    if (data.emojis.hasOwnProperty(emoji)) {
      emojiData = data.emojis[emoji];
    }
  } else if (emoji.custom) {
    emojiData = emoji;

    emojiData.search = buildSearch({
      short_names: emoji.short_names,
      name: emoji.name,
      keywords: emoji.keywords,
      emoticons: emoji.emoticons,
    });

    emojiData.search = emojiData.search.join(',');
  } else if (emoji.id) {
    if (data.short_names.hasOwnProperty(emoji.id)) {
      emoji.id = data.short_names[emoji.id];
    }

    if (data.emojis.hasOwnProperty(emoji.id)) {
      emojiData = data.emojis[emoji.id];
    }
  }

  emojiData.emoticons = emojiData.emoticons || [];
  emojiData.variations = emojiData.variations || [];

  if (emojiData.variations && emojiData.variations.length) {
    emojiData = JSON.parse(JSON.stringify(emojiData));
    emojiData.unified = emojiData.variations.shift();
  }

  return emojiData;
}

function intersect(a, b) {
  let aSet = new Set(a);
  let bSet = new Set(b);
  let intersection = new Set(
    [...aSet].filter(x => bSet.has(x))
  );

  return Array.from(intersection);
}

export { getData, getSanitizedData, intersect };
