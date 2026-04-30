# Journal

## 2026-04-29 — Add Dark/Light Mode Toggle to Blog Theme

### What was changed and why
Added a dark/light mode toggle to the blog theme header. The initial theme value is based on the user's system configuration (`prefers-color-scheme`), and the preference is persisted in `localStorage` so it survives page reloads.

### Files touched

- **themes/shami.blog/layouts/_default/baseof.html**
  - Changed body class from `bg-gray-100` to `bg-light-body text-light-text` (dark mode CSS variables now control the actual colors)
  - Added `toggleTheme()` JavaScript function at the bottom of the page

- **themes/shami.blog/layouts/partials/head.html**
  - Added inline script at the very top of `<head>` (before any CSS loads) to detect the current theme preference — checks `localStorage` first, then falls back to `window.matchMedia('(prefers-color-scheme: dark)')`
  - Added a `change` event listener on `matchMedia` so the theme auto-updates if the user changes their OS preference (only when no manual preference is saved)
  - Added link to the new `dark-mode.css` stylesheet

- **themes/shami.blog/layouts/partials/header.html**
  - Added `position: relative` to the header for toggle button positioning
  - Added a circular toggle button with sun/moon SVG icons
  - Moon icon shows in light mode; sun icon shows in dark mode

- **themes/shami.blog/assets/dark-mode.css** (new file)
  - Defines CSS custom properties for all theme colors (light mode in `:root`, dark mode in `html.dark`)
  - Overrides all hardcoded Tailwind colors across the site: header, body, content cards, sidebar, footer, code blocks, links, borders, search inputs, and pagination buttons
  - Styles the theme toggle button with hover effects
  - Adds smooth transitions for theme switching (applied only to specific elements, not `*`, for performance)

### Decisions made with rationale
- **CSS Variables over Tailwind `dark:` variants**: The theme's CSS (`hugo.css`) is a pre-compiled Tailwind file that was not built with dark mode support enabled (no `darkMode: 'class'` in tailwind.config.js). Rather than requiring a rebuild of the CSS pipeline, I used CSS custom properties with `html.dark` overrides. This is self-contained and doesn't require any build tooling changes.
- **Inline script before CSS**: The theme detection script is placed at the very top of `<head>`, before any stylesheets load. This prevents a flash of incorrect theme (FOUC) by ensuring the `dark` class is set on the `<html>` element before the browser starts painting.
- **localStorage persistence with system fallback**: User's manual choice is saved in `localStorage`. If no preference is saved, the system preference (`prefers-color-scheme`) is used. A `change` listener ensures the site stays in sync with OS-level changes when no manual override exists.
- **`!important` overrides**: Since Tailwind classes have high specificity in the compiled CSS, `!important` was necessary for the CSS variable overrides. This is a known trade-off when working with pre-compiled utility CSS.

### Verification
- Reviewed all layout templates (`baseof.html`, `header.html`, `head.html`, `list.html`, `single.html`, `sidebar.html`, `footer.html`, `404.html`) to ensure all color elements are covered by the dark mode CSS overrides
- Hugo is not installed in the current environment, so a live build could not be tested

### Known issues or follow-up items
- The `bg-white` CSS selector `.px-8.py-5.bg-white` in dark-mode.css relies on the exact Tailwind class combination. If the markup changes, this selector may need updating. Consider using a semantic class instead if this becomes fragile.
- Highlight.js code blocks use a generic dark background in dark mode rather than switching to a specific dark syntax theme (e.g., `vs2015` to `monokai`). Could be improved by conditionally loading a different HLJS theme CSS.
- The `vs2015.min.css` Highlight.js theme is actually already a dark theme, so code blocks may look inconsistent against dark backgrounds in light mode vs. dark mode. The CSS override `html.dark .hljs { background: var(--bg-highlight) }` addresses this partially.

## 2026-04-29 — Dark mode pagination support

### What was changed and why
Added dark mode CSS overrides for pagination classes (`bg-blue-300`, `hover:bg-blue-100`) that were used in the navigation partial.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added `.bg-blue-300` and `.hover\:bg-blue-100:hover` overrides

---

## 2026-04-29 — Dark background for code blocks in light mode

### What was changed and why
Code blocks had inconsistent colors in light mode (inline code was light gray, highlighted code blocks were dark). Made all code blocks use a dark background (`#1e1e1e`) with light text (`#d4d4d4`) for consistency with the vs2015 highlight.js theme.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Updated `code`, `:not(pre) > code`, and `.hljs` rules to use dark backgrounds in all modes

---

## 2026-04-29 — H3 heading font weight adjustment

### What was changed and why
Made `.article h3` headings bold, then reduced from `bold` (700) to `600` (semibold) at user request for a softer emphasis.

### Files touched
- **themes/shami.blog/assets/hugo.css** — Added `font-weight: 600` to `.article h3` rule

---

## 2026-04-29 — Fix raw HTML warnings in markdown content

### What was changed and why
Hugo's Goldmark renderer was warning about raw HTML being omitted in three posts. Fixed the files instead of enabling `unsafe` markup:
- Keyboard shortcuts (`<Super>`, `<Alt>`) were being parsed as HTML tags — wrapped in backticks as inline code
- YouTube embeds used raw `<iframe>`/`<div>` — replaced with `{{< youtube >}}` shortcode
- Spotlight gallery used raw `<div>`/`<a>` — replaced with a new `{{< spotlight >}}` shortcode

### Files touched
- **content/post/2008/tips-for-keyboard-shortcuts-under-gnome.md** — Wrapped keyboard shortcuts in backticks
- **content/post/2016/responsive-youtube-videos-with-hexo.md** — Replaced raw HTML with `{{< youtube >}}` shortcode
- **content/post/2009/fixing-banders-xbox-360/index.md** — Replaced raw HTML with `{{< spotlight >}}` shortcode
- **themes/shami.blog/layouts/shortcodes/spotlight.html** (new) — Spotlight lightbox shortcode

### Decisions made with rationale
- Chose to fix content files rather than enable `unsafe` markup, per user request. This is safer and follows Hugo best practices.

---

## 2026-04-29 — Make YouTube shortcode responsive

### What was changed and why
The YouTube shortcode used Tailwind aspect-ratio classes (`aspect-w-16`, `aspect-h-9`) that don't exist in the compiled CSS (plugin was commented out). Replaced with inline styles using the standard `padding-bottom` responsive embed technique.

### Files touched
- **themes/shami.blog/layouts/shortcodes/youtube.html** — Replaced Tailwind classes with inline responsive styles

---

## 2026-04-29 — Configurable Open Graph preview image

### What was changed and why
The `og:image` was hardcoded to `https://shami.blog/profile.jpg`. Made it configurable via `config.toml` with per-page override support via front matter `images` or `featured_image` params. Also switched from hardcoded domain to `absURL` for portability.

### Files touched
- **config.toml** — Added `images = ["/profile.jpg"]` to `[params]`
- **themes/shami.blog/layouts/partials/head.html** — Dynamic `og:image` resolution with fallback chain: page `images` → page `featured_image` → site `images` → default `/profile.jpg`

---

## 2026-04-29 — Replace highlight.js with Hugo Chroma

### What was changed and why
Removed highlight.js (CDN-loaded JS with security concerns) and replaced with Hugo's built-in Chroma syntax highlighter (build-time, no JS, no external dependencies).

### Files touched
- **config.toml** — Added `[markup.highlight]` with `noClasses = true`, `style = "dracula"`, `guessSyntax = true`
- **themes/shami.blog/layouts/partials/head.html** — Removed highlight.js CSS CDN link
- **themes/shami.blog/layouts/_default/baseof.html** — Removed highlight.js JS CDN script and `hljs.highlightAll()` call
- **themes/shami.blog/assets/dark-mode.css** — Replaced `.hljs` selector with `.highlight` (Chroma's wrapper class)

### Decisions made with rationale
- Used `noClasses = true` (inline styles) for simplest setup — no external CSS needed
- Chose "dracula" style for good readability on dark backgrounds
- `guessSyntax = true` auto-detects language when not specified

---

## 2026-04-29 — Horizontal scrollbar for code blocks

### What was changed and why
Code blocks were spilling outside their container. Added `overflow-x: auto` to enable horizontal scrolling.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added `overflow-x: auto` to `.highlight` and `pre`

---

## 2026-04-29 — Empty favicon to prevent 404s

### What was changed and why
Added `<link rel="icon" href="data:,">` to inform browsers that no favicon exists, preventing automatic 404 requests to `/favicon.ico`.

### Files touched
- **themes/shami.blog/layouts/partials/head.html** — Added empty favicon link

---

## 2026-04-29 — Remove rounded edges from code blocks

### What was changed and why
User requested no rounded corners on code blocks.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Removed `border-radius: 6px` from `.highlight`

---

## 2026-04-29 — Fix unclosed code block in 2015 mail server post

### What was changed and why
Found one markdown file with an odd number of fence markers (45). The last code block's closing fence was on the same line as content instead of its own line, so Goldmark didn't recognize it. Moved closing ``` to its own line.

### Files touched
- **content/post/2015/howto-small-mail-server-with-salt-dovecot-and-opensmtpd.md**

### Verification
- Ran check across all .md files — no more odd fence counts

### Known issues or follow-up items
- None currently

---

## 2026-04-29 — Typography & font improvements

### What was changed and why
Improved the blog's typography and readability per UI suggestion. Changed the font stack to a modern system font stack, increased base font size, and improved line height for long-form reading.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added font stack (`Inter, system-ui, -apple-system, ...`), base font size `16px`, line-height `1.7`

### Decisions made with rationale
- Kept changes strictly to font properties (font-family, font-size, line-height) — no margin/padding changes as requested by user
- Used `Inter` as the preferred font with a system-ui fallback chain for broad compatibility and fast loading (no web font download needed)

---

## 2026-04-29 — Card visual distinction for post listing

### What was changed and why
Posts on the listing page blended into each other. Added subtle card borders, a blue left accent border, and a hover shadow to create visual rhythm and improve scanning.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added `border`, `border-left: 4px solid var(--text-link)`, and `box-shadow` to `.px-8.py-5.bg-white` cards; hover state increases shadow depth

---

## 2026-04-29 — Accent colors and code block polish

### What was changed and why
Added accent colors for personality and improved code block styling:
- Article headings (`h1`–`h4`) now use the accent color (blue)
- Post date labels styled with secondary color and italic
- Code block containers (`.highlight`) got padding, a subtle border, and a distinct dark background tint

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added `--accent` CSS variable, heading accent color rules, date label styling, and enhanced `.highlight` container with `padding: 1em` and `border: 1px solid #374151`

---

## 2026-04-29 — Post listing metadata (reading time, category badges)

### What was changed and why
Post listing only showed dates. Added reading time and category badges to help users quickly scan and decide what's relevant.

### Files touched
- **themes/shami.blog/layouts/_default/list.html** — Replaced single date line with a `.post-meta` flex row containing: date (`<time>`), reading time (`.post-reading-time` via Hugo's `.ReadingTime`), and category badges (`.post-badge` from `.Params.categories`)
- **themes/shami.blog/assets/dark-mode.css** — Added styling for `.post-meta` (centered flex row), `.post-badge` (accent-colored pill), and `.post-dot` (separator)

### Known issues or follow-up items
- No posts currently use `tags` in front matter, so tag badges are not shown. The template can easily be extended with `{{ with .Params.tags }}` if tags are added later

---

## 2026-04-29 — Add reading time to single post pages

### What was changed and why
Single post pages only showed the date. Added reading time and category badges to match the listing page layout.

### Files touched
- **themes/shami.blog/layouts/_default/single.html** — Replaced single date line with the same `.post-meta` flex row (date, reading time, category badges) used on the listing page

---

## 2026-04-29 — Hide pagination when only one page

### What was changed and why
The pagination bar was showing even when there was only one page of results. Wrapped the navigation partial content in `{{ if gt $pag.TotalPages 1 }}` so it only renders when there are multiple pages.

### Files touched
- **themes/shami.blog/layouts/partials/navigation.html** — Added conditional around the entire pagination block

---

## 2026-04-29 — Code block improvements: copy button, line numbers

### What was changed and why
Extensive code blocks (like the Forgejo post) needed better usability. Added:
- **Copy-to-clipboard button** — appears on hover in the top-right corner of code blocks, shows "Copied!" feedback
- **Line numbers** — enabled via Hugo Chroma config for all code blocks

### Files touched
- **config.toml** — Added `lineNos = true`, `lineNumbersInTable = false` to `[markup.highlight]`
- **themes/shami.blog/layouts/_default/baseof.html** — Added copy-to-clipboard JS that attaches a button to every `<pre>` block
- **themes/shami.blog/assets/dark-mode.css** — Added `.code-copy-btn` styling (absolute positioning, hover reveal, dark theme matching)

---

## 2026-04-29 — Updated tagline, moved to config

### What was changed and why
Changed the blog tagline from "Sysadmin, Because Even Developers Need Heroes" to "DevOps because uptime is not optional" — more descriptive of the current content scope. Moved it to config.toml so it can be changed in one place.

### Files touched
- **config.toml** — Added `tagline` parameter under `[params]`
- **themes/shami.blog/layouts/partials/header.html** — Now reads tagline from `.Site.Params.tagline`
- **themes/shami.blog/layouts/partials/head.html** — Uses `$tagline` variable for home page meta descriptions, with fallback default

---

## 2026-04-29 — Removed blue left accent border from cards

### What was changed and why
User requested removal of the blue left accent border on post cards. The regular border and shadow remain for visual separation.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Removed `border-left: 4px solid var(--text-link)` from `.px-8.py-5.bg-white`
