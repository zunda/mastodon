![Mastodon](https://i.imgur.com/NhZc40l.png)
========

[![Build Status](https://img.shields.io/circleci/project/github/tootsuite/mastodon.svg)][circleci]
[![Code Climate](https://img.shields.io/codeclimate/maintainability/tootsuite/mastodon.svg)][code_climate]

[circleci]: https://circleci.com/gh/tootsuite/mastodon
[code_climate]: https://codeclimate.com/github/tootsuite/mastodon

Mastodon is a **free, open-source social network server** based on **open web protocols** like ActivityPub and OStatus. The social focus of the project is a viable decentralized alternative to commercial social media silos that returns the control of the content distribution channels to the people. The technical focus of the project is a good user interface, a clean REST API for 3rd party apps and robust anti-abuse tools.

Click on the screenshot below to watch a demo of the UI:

[![Screenshot](https://i.imgur.com/qrNOiSp.png)][youtube_demo]

[youtube_demo]: https://www.youtube.com/watch?v=IPSbNdBmWKE

**Ruby on Rails** is used for the back-end, while **React.js** and Redux are used for the dynamic front-end. A static front-end for public resources (profiles and statuses) is also provided.

If you would like, you can [support the development of this project on Patreon][patreon] or [Liberapay][liberapay].

[patreon]: https://www.patreon.com/user?u=619786
[liberapay]: https://liberapay.com/Mastodon/

---

## Resources

- [Frequently Asked Questions](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md)
- [Use this tool to find Twitter friends on Mastodon](https://bridge.joinmastodon.org)
- [API overview](https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md)
- [List of Mastodon instances](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/List-of-Mastodon-instances.md)
- [List of apps](https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md)
- [List of sponsors](https://joinmastodon.org/sponsors)

## Features

**No vendor lock-in: Fully interoperable with any conforming platform**

It doesn't have to be Mastodon, whatever implements ActivityPub or OStatus is part of the social network!

**Real-time timeline updates**

See the updates of people you're following appear in real-time in the UI via WebSockets. There's a firehose view as well!

**Federated thread resolving**

If someone you follow replies to a user unknown to the server, the server fetches the full thread so you can view it without leaving the UI

**Media attachments like images and short videos**

Upload and view images and WebM/MP4 videos attached to the updates. Videos with no audio track are treated like GIFs; normal videos are looped - like vines!

**OAuth2 and a straightforward REST API**

Mastodon acts as an OAuth2 provider so 3rd party apps can use the API

**Fast response times**

Mastodon tries to be as fast and responsive as possible, so all long-running tasks are delegated to background processing

**Deployable via Docker**

You don't need to mess with dependencies and configuration if you want to try Mastodon, if you have Docker and Docker Compose the deployment is extremely easy

---

## Development

Please follow the [development guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Development-guide.md) from the documentation repository.

## Deployment

There are guides in the documentation repository for [deploying on various platforms](https://github.com/tootsuite/documentation#running-mastodon).

## Contributing

You can open issues for bugs you've found or features you think are missing. You can also submit pull requests to this repository. [Here are the guidelines for code contributions](CONTRIBUTING.md)

**IRC channel**: #mastodon on irc.freenode.net

## License

Copyright (C) 2016-2018 Eugen Rochko & other Mastodon contributors (see AUTHORS.md)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

---

## Extra credits

The elephant friend illustrations are created by [Dopatwo](https://mastodon.social/@dopatwo)

## Modifications

[This repository](https://github.com/zunda/mastodon/tree/zunda-ninja-master-on-heroku) contains modifications for smoother operation on Heroku by [zunda](https://github.com/zunda) to the [original version](https://github.com/tootsuite/mastodon). Namely:

- Apr 2017: Modified [`Procfile`](./Procfile) so that the `web` dyno can run the main app (`puma`), worker (`sidekiq`), and/or streaming API (`npm`). Set config vars `RUN_WEB`, `RUN_WORKER`, and/or `RUN_STREAMING` to `true` to run corresponding service.
  - You may want to watch memory use of the piggybacking dyno and adjust `MAX_THREADS` and `WEB_CONCURRENCY`.
  - `puma` and `npm` cannot reside on the same dyno.
- Apr 2017: Added [`.profile.d/mastodon-nodejs-dataurl.sh`](./.profile.d/mastodon-nodejs-dataurl.sh) to obtain connection information for streaming API when dyno is starting.
- Apr 2017: Add `release` line to [`Procfile`](./Procfile) to migrate database [on each deploy](https://devcenter.heroku.com/articles/release-phase).
