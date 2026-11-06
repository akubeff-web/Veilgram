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
  read receipts (chats, voice and video messages) or story views. After you send a message (which
  makes the server show you online) it sends offline right away. In a chat, a small pill with an eye
  shows how many messages the server still counts as unread; tapping it sends the read receipt for
  that chat only.
- **Always Online**: keeps you online while the app runs, also when another session logs off.
- **Deleted messages stay in the chat**: messages deleted on the server by the other side or an admin
  keep their text and media, marked with a trash icon next to the time, and are listed in the
  deleted messages log. Secret chats, scheduled messages, quick replies and messages you delete
  yourself are deleted as usual.
- **Edit history**: earlier versions of messages the other side edits are kept (long press → Edit
  History). **Details** in the same menu shows message, chat and author ids and exact times.
- **Confirm stickers and voice**: a sticker asks before sending; a voice or video message opens its
  preview instead of sending on release.
- **Filters**: messages from blocked users are hidden in groups and channels; incoming messages with
  chosen words are hidden everywhere.
- **Protected content**: copying, forwarding, saving and screenshots in chats that forbid them;
  view-once and timed media do not start their timer when opened.
- **Ghost exceptions**: ghost mode can be turned off for single chats (long press on the chat avatar);
  the same menu jumps to the first message and counts messages per participant.
- **Read All Chats**, **auto-reply** once to new chats, **streamer mode**, hiding the own phone number,
  the user id and registration month in profiles, switches for each Premium element, and faster
  downloads and uploads.
- **Unlimited accounts** without Premium. Every signed-in account stays connected, so many of them
  cost memory and battery.
- **Tab bar and stories**: Contacts, Calls and News tabs and the stories row can be hidden.
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

## Getting the IPA

1. Open the repository on GitHub → **Actions** → **Personal build** → **Run workflow** (branch `main`).
2. When the run is green, open it and download **Veilgram.ipa** from the **Artifacts** section at the
   bottom of the run page (a plain .ipa, not a zip); artifacts are kept for 14 days.
3. Install `Veilgram.ipa` with Sideloadly or AltStore, which re-sign it with your Apple ID
   (and can change the bundle identifier).

## Notes

- The "Open Telegram" button opens `tg://` links. Veilgram keeps Telegram's own URL schemes, so with
  both apps installed iOS decides which of them handles the link.
- Auto-archive works on the client: if the app is closed when the very first message of a new chat
  arrives, that push notification still has sound; the chat is archived and muted on the next launch.
