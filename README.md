# Veilgram

Veilgram is an **unofficial** personal build of the Telegram iOS client, based on
[Telegram-iOS](https://github.com/TelegramMessenger/Telegram-iOS). It is not affiliated with,
endorsed by or supported by Telegram. The Telegram name and the paper plane logo belong to
Telegram; Veilgram does not claim them as its own.

- Upstream: `TelegramMessenger/Telegram-iOS`, branch `master`, imported at commit
  `279f89e4d4f63f17227bf877dc3d8990f22ecd58`.
- License: GNU General Public License v2.0 (see [LICENSE](LICENSE)), the same as upstream.
  The source code of every build is this repository.
- Icons: [Lucide](https://lucide.dev) (ISC license).
- The original upstream README is kept in [docs/UPSTREAM_README.md](docs/UPSTREAM_README.md).

## Features

All of them can be switched in Settings → Veilgram, and take effect immediately.

- **Ghost mode**: the app never sends the online status (`account.updateStatus`), typing activity,
  read receipts (chats, voice and video messages) or story views. Sending a message still makes the
  server show you online, as it always does.
- **Deleted messages stay in the chat**: messages deleted on the server by the other side or an admin
  keep their text and media, marked with a trash icon next to the time. Secret chats, scheduled
  messages, quick replies and messages you delete yourself are deleted as usual.
- **Up to 10 accounts** without Premium.
- **Tab bar**: Contacts, Calls and News tabs can be hidden.
- **Auto-archive and mute new chats** without Premium (client-side): the first incoming message from a
  non-contact moves the chat to the archive and mutes it. If the app is closed, the push for that very
  first message still arrives with sound.
- **"Open Telegram" button** on the login code screen.

## Building

There is no local build: the IPA is built by GitHub Actions (`.github/workflows/personal-build.yml`,
started manually from the Actions tab). The workflow needs two repository secrets, `TG_API_ID` and
`TG_API_HASH`, obtained at https://my.telegram.org. The IPA is uploaded as a workflow artifact
(kept for 14 days) and is never published as a release, because it contains these keys.

The IPA is signed with fake codesigning and has to be re-signed for installation, e.g. with
AltStore or Sideloadly (which also change the bundle identifier).
