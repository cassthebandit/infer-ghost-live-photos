# Live Photos for Ghost

iPhone Live Photos on Ghost CMS — no plugins, no theme modifications, no dependencies.

Short videos (≤5 seconds) uploaded via Ghost's Video card are automatically detected and displayed as living photos: no player controls, crossfade blur transitions on scroll, lazy preloading, optional looping with dwell, and `prefers-reduced-motion` support. Longer videos keep Ghost's normal player.

**Live demo:** [infer.blog](https://infer.blog)
**Blog post:** [Bringing iPhone Live Photos to Ghost](#) [Daniel: confirm URL once published]

---

## How it works

A Live Photo is two files: a still HEIC and a ~3-second MOV. The MOV gets converted to H.264 MP4, uploaded to a Ghost Video card, and Code Injection handles the rest. Duration is the differentiator — anything under 5 seconds becomes a live photo automatically.

The JS creates a poster overlay from Ghost's custom thumbnail, observes viewport intersection to trigger playback, and uses the Web Animations API for a 350ms blur dissolve crossfade between the still and the video. Videos start with `preload="none"` and only download when the reader scrolls close.

## Setup

### 1. Install ffmpeg

```bash
brew install ffmpeg
```

### 2. Create the Quick Action

Open **Automator** → New → **Quick Action**. Set "Workflow receives current" to **movie files** in **Finder**. Drag in a **Run Shell Script** action, set "Pass input" to **as arguments**, and paste the contents of `convert-to-ghost-mp4.sh`. Save as **"Convert to Ghost MP4."**

Right-click any `.mov` → Quick Actions → Convert to Ghost MP4. Output appears in the same folder as `filename_ghost.mp4`.

The script uses `/opt/homebrew/bin/ffmpeg` (Apple Silicon default). Check `which ffmpeg` and adjust if yours differs.

### 3. Add the CSS to Site Header

Ghost Admin → Settings → Code injection → **Site Header**

Add the following CSS inside your existing `<style>` block, or wrap it in `<style>...</style>`:

### 4. Add the JS to Site Footer

Ghost Admin → Settings → Code injection → **Site Footer**

Paste the entire contents of `site-footer.html`.

### 5. Upload a Live Photo

1. Option-drag a Live Photo from Photos.app to the desktop
2. Right-click the `.mov` → Quick Actions → Convert to Ghost MP4
3. In Ghost editor, add a Video card and upload the `_ghost.mp4` file
4. Set a custom thumbnail (the `.jpeg` from the same export)
5. Toggle **Loop** on if you want the clip to repeat
6. Publish

The Code Injection detects duration and handles everything else. No per-post configuration needed beyond the optional Loop toggle.

## Files

```
├── README.md
├── LICENSE
├── convert-to-ghost-mp4.sh    ← macOS Automator Quick Action script
└── site-footer.html            ← Site Footer JS (Ghost Code Injection)
```

## Features

- **Crossfade transitions** — 350ms blur dissolve between still and video (Web Animations API)
- **Lazy preloading** — videos start with `preload="none"`, download one viewport height before visible
- **Scroll-triggered playback** — plays at 50% visible, pauses when scrolled away
- **Click/tap replay** — replays from start with crossfade
- **Loop with dwell** — respects Ghost's Loop toggle, 4-second dwell between cycles
- **`prefers-reduced-motion`** — static frame, no playback, real-time toggle support
- **No theme modifications** — everything lives in Code Injection, survives Ghost updates

## Ghost quirks

**Poster attribute is a spacer GIF.** Ghost sets the video `poster` attribute to a transparent image from `spacergif.org`, not the actual thumbnail. The real thumbnail URL lives on the `<figure>` element as `data-kg-custom-thumbnail`. The JS reads from the figure, not the video.

**Editor preview doesn't show the effect.** Code Injection runs on the published site, not in Ghost Admin. The normal video player in the editor is expected.

**Email fallback.** Video doesn't work in email clients. Ghost includes a static frame in email versions.

## Safari on Coolify

If you're running Ghost on [Coolify](https://coolify.io/) and Safari won't play video, the problem is Coolify's Traefik gzip middleware compressing `video/mp4` and breaking byte-range responses. This is a [filed Coolify bug](https://github.com/coollabsio/coolify/issues/5222).

The fix is a Traefik Dynamic Configuration that routes `/content/media/` without gzip:

**Coolify → Servers → Proxy → Dynamic Configurations → `ghost-media-no-compress.yaml`:**

```yaml
http:
  routers:
    ghost-media:
      rule: "Host(`your-domain.com`) && PathPrefix(`/content/media/`)"
      service: ghost-media-service
      entryPoints:
        - http
      priority: 100
  services:
    ghost-media-service:
      loadBalancer:
        servers:
          - url: "http://your-ghost-container:2368"
```

Replace `your-domain.com` and the container URL with your own. See the [blog post](#) for the full debugging story.

## Stack

Built and tested on:

- Ghost v5 with [Solo](https://github.com/TryGhost/Solo) theme (unmodified)
- [Coolify](https://coolify.io/) for hosting (Docker + Traefik)
- [Cloudflare](https://www.cloudflare.com/) free tier CDN
- [ffmpeg](https://ffmpeg.org/) for video conversion
- macOS with Apple Silicon (Automator Quick Action)

Should work with any Ghost v5 installation and theme. The CSS targets Ghost's `kg-video-card` classes, which are part of Ghost's card system, not theme-specific.

## License

MIT — see [LICENSE](LICENSE).

---

Built with Claude. Directed by [Daniel Soteldo](https://infer.blog/about/).
