import emojify from 'mastodon/emoji';
import { length } from 'stringz';
import { default as dateFormat } from 'date-fns/format';
import distanceInWordsStrict from 'date-fns/distance_in_words_strict';
import { delegate } from 'rails-ujs';

require.context('../images/', true);

const parseFormat = (format) => format.replace(/%(\w)/g, (_, modifier) => {
  switch (modifier) {
  case '%':
    return '%';
  case 'a':
    return 'ddd';
  case 'A':
    return 'ddd';
  case 'b':
    return 'MMM';
  case 'B':
    return 'MMMM';
  case 'd':
    return 'DD';
  case 'H':
    return 'HH';
  case 'I':
    return 'hh';
  case 'l':
    return 'H';
  case 'm':
    return 'M';
  case 'M':
    return 'mm';
  case 'p':
    return 'A';
  case 'S':
    return 'ss';
  case 'w':
    return 'd';
  case 'y':
    return 'YY';
  case 'Y':
    return 'YYYY';
  default:
    return `%${modifier}`;
  }
});

document.addEventListener('DOMContentLoaded', () => {
  [].forEach.call(document.querySelectorAll('.emojify'), (content) => {
    content.innerHTML = emojify(content.innerHTML);
  });

  [].forEach.call(document.querySelectorAll('time[data-format]'), (content) => {
    const format = parseFormat(content.dataset.format);
    const formattedDate = dateFormat(content.getAttribute('datetime'), format);
    content.textContent = formattedDate;
  });

  [].forEach.call(document.querySelectorAll('time.time-ago'), (content) => {
    const timeAgo = distanceInWordsStrict(new Date(), content.getAttribute('datetime'), {
      addSuffix: true,
    });
    content.textContent = timeAgo;
  });
});

delegate(document, '.video-player video', 'click', ({ target }) => {
  if (target.paused) {
    target.play();
  } else {
    target.pause();
  }
});

delegate(document, '.media-spoiler', 'click', ({ target }) => {
  target.style.display = 'none';
});

delegate(document, '.webapp-btn', 'click', ({ target, button }) => {
  if (button !== 0) {
    return true;
  }
  window.location.href = target.href;
  return false;
});

delegate(document, '.status__content__spoiler-link', 'click', ({ target }) => {
  const contentEl = target.parentNode.parentNode.querySelector('.e-content');
  if (contentEl.style.display === 'block') {
    contentEl.style.display = 'none';
    target.parentNode.style.marginBottom = 0;
  } else {
    contentEl.style.display = 'block';
    target.parentNode.style.marginBottom = null;
  }
  return false;
});

delegate(document, '.account_display_name', 'input', ({ target }) => {
  const nameCounter = document.querySelector('.name-counter');
  nameCounter.textContent = 30 - length(target.value);
});

delegate(document, '.account_note', 'input', ({ target }) => {
  const noteCounter = document.querySelector('.note-counter');
  noteCounter.textContent = 160 - length(target.value);
});
