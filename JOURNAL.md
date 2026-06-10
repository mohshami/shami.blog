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

---

## 2026-04-29 — Added gap between social media icons

### What was changed and why
Added spacing between the Twitter and LinkedIn logos in the sidebar for better visual separation.

### Files touched
- **themes/shami.blog/layouts/partials/sidebar.html** — Added `style="gap: 1em;"` to the flex container holding social links

---

## 2026-04-29 — Made entire pagination button clickable

### What was changed and why
Pagination buttons were only clickable on the text/number. Made the entire button area clickable using negative margins on the `<a>` tag.

### Files touched
- **themes/shami.blog/assets/dark-mode.css** — Added `.btn-paginate a { display: block; margin: -0.5rem -1rem; padding: 0.5rem 1rem; }` to expand the link to fill the entire button

---

## 2026-04-29 — Simplified "Read More" link

### What was changed and why
The "Read More - {Post Title}" pattern was redundant since the title is already displayed above. Simplified to "Read more →".

### Files touched
- **themes/shami.blog/layouts/_default/list.html** — Changed link text to `Read more &rarr;`
- **themes/shami.blog/layouts/_default/term.html** — Same change

---

## 2026-04-29 — Replaced social icon PNGs with inline SVGs

### What was changed and why
Twitter and LinkedIn logos were loaded as separate PNG files (`/twitter.png`, `/linkedin.png`). Replaced with inline SVGs for better scaling, no external requests, and proper accessibility with `aria-label`.

### Files touched
- **themes/shami.blog/layouts/partials/sidebar.html** — Replaced `<img>` tags with inline `<svg>` elements (Twitter bird + LinkedIn "in" logo), added `aria-label` to each link

---

## 2026-04-29 — Added SVG favicon

### What was changed and why
Replaced the empty `data:,` favicon placeholder with a proper SVG favicon showing "S" (blog initial) on a blue rounded-square background. Reverted from "SB" to "S" for simplicity.

### Files touched
- **themes/shami.blog/static/favicon.svg** (new) — 32×32 SVG with `#2563eb` rounded-square background and white "S" text
- **themes/shami.blog/layouts/partials/head.html** — Updated `<link rel="icon">` to point to `/favicon.svg`

---

## 2026-04-29 — Adjusted About Me card social icon spacing

### What was changed and why
Equalized and reduced the spacing above and below the social icons in the About Me sidebar card. Final values: `0.8rem` above and below (reduced in two iterations from the original `1.25rem`).

### Files touched
- **themes/shami.blog/layouts/partials/sidebar.html** — Set `margin-top: 1rem` on social icons paragraph, added `style="padding-bottom: 1rem;"` to About Me card

---

## 2026-05-28 — Fixed extra space before punctuation after hyperlinks

### What was changed and why
Hyperlinks in the middle of sentences followed by punctuation (e.g., `[link](url),`) were rendering with an unwanted space before the punctuation mark. This was caused by a trailing newline (`\n`) in the `render-link.html` Hugo render-hook template. Hugo included that newline in the rendered HTML output, which browsers collapsed into a visible space between the link and the punctuation.

### Files touched
- **themes/shami.blog/layouts/_default/_markup/render-link.html** — Removed the trailing newline so the template outputs the `<a>` tag immediately followed by whatever text comes next in the markdown.

### Decisions made with rationale
- Chose to fix at the template level rather than with CSS (e.g., `white-space: nowrap`) because CSS-based fixes can have side effects like preventing long links from wrapping on narrow viewports. Removing the extraneous newline is the root-cause fix.

### Verification
- Rebuilt the site with `hugo` and inspected generated HTML.
- Confirmed that links followed by commas, periods, etc., no longer have a newline/space between `</a>` and the punctuation (e.g., `...<a href="...">Microsoft</a>, you can't...` instead of `...<a href="...">Microsoft</a>\n, you can't...`).

---

## 2026-06-10 — Extracted search form into reusable partial

### What was changed and why
The Google search form existed in two places: once in the mobile header area (`baseof.html`) and once in the sidebar (`sidebar.html`). Both forms were identical but had duplicated markup. Extracted the form into a single reusable partial to eliminate duplication and make future changes easier.

### Files touched
- **themes/shami.blog/layouts/partials/search-form.html** (new) — Contains the shared Google search form markup
- **themes/shami.blog/layouts/_default/baseof.html** — Replaced inline form with `{{ partial "search-form.html" . }}`
- **themes/shami.blog/layouts/partials/sidebar.html** — Replaced inline form with `{{ partial "search-form.html" . }}`

### Decisions made with rationale
- Chose a **partial** instead of a Hugo shortcode because shortcodes are intended for use inside markdown content, whereas partials are the correct abstraction for reusable fragments inside templates/layouts.

### Verification
- Verified the partial file was created and both templates reference it correctly.
- No functional changes expected; the visible/hidden behavior (`md:hidden` vs `hidden md:block`) remains controlled by the parent containers in each template.

---

## 2026-06-10 — Replaced Google search with Pagefind

### What was changed and why
Replaced the Google webform search with Pagefind, a fully static search engine that indexes the built HTML files. This removes the external Google dependency and gives instant search results without sending queries to a third party. Pagefind was configured to **only index individual blog posts**, skipping listing pages, taxonomy pages, and paginator pages.

### Files touched
- **package.json** — Added `pagefind` as a devDependency and created `build` and `dev` npm scripts
- **mise.toml** — Added `node` and `npm` tool definitions for the project
- **themes/shami.blog/layouts/partials/head.html** — Added `<link>` and `<script>` tags for Pagefind UI CSS and JS
- **themes/shami.blog/layouts/partials/search-form.html** — Replaced Google form with a Pagefind UI container (`<div id="...">`) and initialization script
- **themes/shami.blog/layouts/_default/baseof.html** — Added `data-pagefind-ignore` to `<html>` to skip all pages by default; passed `"search-mobile"` ID to the search partial
- **themes/shami.blog/layouts/partials/sidebar.html** — Passed `"search-desktop"` ID to the search partial
- **themes/shami.blog/layouts/_default/single.html** — Added `data-pagefind-body` to the article div so only blog posts are indexed

### Decisions made with rationale
- **Used a partial with parameterized IDs** (`search-mobile` / `search-desktop`) because Pagefind UI needs a unique target element per instance. The responsive containers (`md:hidden` / `hidden md:block`) already ensure only one is visible at a time.
- **Added `data-pagefind-ignore` to `<html>` and `data-pagefind-body` to posts** instead of CLI filtering. This is the native Pagefind way to control indexing and keeps the build command simple (`pagefind --site public`).
- **Installed Pagefind via npm** rather than a global binary so the version is pinned in `package.json` and works across environments.
- **Used the Default Pagefind UI** (`pagefind-ui.js`) rather than the newer Component UI. The Component UI is recommended for new projects, but the Default UI is simpler to drop into existing containers and is fully supported.

### How to test

**Production build:**
```bash
npm run build
# Serves the public/ directory with search working
```

**Development server:**
```bash
npm run dev
# 1. Builds the site to public/
# 2. Runs pagefind to index only posts
# 3. Starts hugo server on http://localhost:1313
```

> **Note:** `hugo server` watches for changes and rebuilds, but it does **not** automatically re-run Pagefind. If you edit content and want the search index updated, stop the server and re-run `npm run dev`.

### Verification
- Ran `npm run build` successfully. Pagefind reported:
  - `Found a data-pagefind-body element on the site. Ignoring pages without this tag.`
  - `Indexed 1 language, Indexed 135 pages` (matching the 135 individual blog posts).
- Ran `npm run dev` and confirmed `hugo server` serves the pre-built pagefind assets from `public/pagefind/`.
- `curl` verified that both `pagefind-ui.js` and `pagefind-ui.css` are reachable at `//localhost:1313/pagefind/...`.
- Verified that the old Google form (`//google.com/search`) no longer appears in the generated HTML.

### Known issues / follow-up
- The Default Pagefind UI styling may need minor CSS tweaks to match the existing Tailwind theme perfectly.
- Consider switching to the Pagefind Component UI in the future for a search modal and better accessibility (Pagefind recommends this as of v1.5.0).

---

## 2026-06-10 — Moved search from sidebar to main content area

### What was changed and why
The search box was split across two locations: a mobile-only instance in the main content area (`md:hidden`) and a desktop-only instance in the sidebar (`hidden md:block`). The user wanted the search results to appear in the content section, not the sidebar. Consolidated into a single search instance visible on all screen sizes in the main content column.

### Files touched
- **themes/shami.blog/layouts/_default/baseof.html** — Replaced the `md:hidden` mobile-only search wrapper with a single `px-8 py-5 bg-white m-3 rounded-lg` container in the main content area. Updated the partial call to use `id "search"`.
- **themes/shami.blog/layouts/partials/sidebar.html** — Removed the `hidden md:block` desktop-only search wrapper entirely.

### Decisions made with rationale
- Removed the dual-instance approach because the Default Pagefind UI renders its results dropdown directly below the search input. Having results in the sidebar would make them cramped and hard to read. Moving the search to the main content area gives the dropdown plenty of horizontal space on both mobile and desktop.
- Kept the same `search-form.html` partial so the UI remains maintainable; only the placement and ID changed.

### Verification
- Rebuilt the site with `hugo` and confirmed via `curl` that only one `id="search"` exists in the generated HTML.
- Confirmed that `search-desktop` and `search-mobile` IDs no longer appear anywhere in the output.
- Ran `npm run dev` and verified the dev server starts cleanly with the search present in the content area.

### Known issues / follow-up
- None.

---

## 2026-06-10 — Reverted search box location, results now in main content area

### What was changed and why
The user wanted the search box back in its original responsive locations (mobile header + desktop sidebar), but with search results rendered in the main content area instead of a dropdown. When results are shown, all other content in that section is hidden. To achieve this, replaced the Pagefind Default UI with a custom integration using the Pagefind JavaScript API directly.

### Files touched
- **themes/shami.blog/layouts/partials/head.html** — Removed `pagefind-ui.css` and `pagefind-ui.js` (Default UI); added `pagefind.js` as a module script
- **themes/shami.blog/layouts/_default/baseof.html** — Reverted to dual search box placement (mobile `md:hidden` + desktop in sidebar); added `#search-results` container in main content area; wrapped `{{- block "main" . }}` in `#main-content` so it can be hidden; added a `<script type="module">` that imports `debouncedSearch` from Pagefind, wires both inputs, and renders results into `#search-results`
- **themes/shami.blog/layouts/partials/sidebar.html** — Re-added the `hidden md:block` desktop-only search wrapper
- **themes/shami.blog/layouts/partials/search-form.html** — Replaced the Pagefind UI container with a plain `<input>` element styled with the existing Tailwind/sprite classes

### Decisions made with rationale
- **Used the Pagefind JS API directly** instead of the Default UI or Component UI because neither supports separating the search input from the results container. The low-level API gives full control over where results are rendered.
- **Loaded `pagefind.js` as `type="module"`** so it works with ES module imports. The module's `import.meta.url` correctly resolves the `/pagefind/` base path for loading WASM and metadata.
- **Used `debouncedSearch` with 200ms debounce** to avoid excessive API calls while typing.
- **Kept both inputs in sync** so typing in either the mobile or desktop input updates the other and triggers a single search.
- **Results are rendered with custom HTML** (not a Pagefind component) so they can be styled to match the existing Tailwind theme.

### How to test

**Production build:**
```bash
npm run build
# Serves the public/ directory with search working
```

**Development server:**
```bash
npm run dev
# 1. Builds the site to public/
# 2. Runs pagefind to index only posts
# 3. Starts hugo server on http://localhost:1313
```

**Manual verification:**
1. Open `http://localhost:1313/` on a desktop browser — the search box should be in the sidebar
2. Open the same page on a mobile viewport (or check the HTML) — the search box should appear at the top of the main content area
3. Type a query in either search box — the main content area should switch to showing search results, hiding the blog posts
4. Clear the search input — the main content area should switch back to showing blog posts

### Verification
- Ran `npm run dev` and confirmed the server starts cleanly.
- `curl` verified that both `search-mobile-input` and `search-desktop-input` exist in the generated HTML.
- `curl` verified that `#search-results` and `#main-content` containers exist in the main content area.
- `curl` verified that no `pagefind-ui` or `google.com/search` references remain in the HTML.
- Pagefind indexing still reports `Indexed 135 pages` (matching the blog post count).

### Known issues / follow-up
- The search results styling is basic (custom HTML with Tailwind classes). Consider refining the look of result excerpts, titles, and empty states.
- `hugo server` does not auto-re-run Pagefind on content changes. Stop and re-run `npm run dev` to refresh the index after editing posts.

---

## 2026-06-10 — Styled search results like article blocks

### What was changed and why
The search results were rendered as plain text links with minimal styling. The user wanted them to match the existing blog post cards (`px-8 py-5 bg-white m-3 rounded-lg` with centered title and `article` content div). Updated the search results rendering to match the article block layout.

### Files touched
- **themes/shami.blog/layouts/_default/baseof.html** — Two changes:
  1. Removed `px-8 py-5 bg-white m-3 rounded-lg` from the outer `#search-results` wrapper so the wrapper itself isn't a card
  2. Updated the results rendering JS to output each result as a `<div class="px-8 py-5 bg-white m-3 rounded-lg">` with `<h2 class="text-3xl font-semibold text-center"><a href="...">...</a></h2>` and `<div class="article">...</div>` matching the `list.html` / `single.html` article blocks

### Decisions made with rationale
- Each search result is its own card so the visual rhythm matches the blog post listing page. This is more familiar to readers than a compact list.
- Removed the outer card styling from `#search-results` to avoid nesting cards inside cards.
- Kept the `<div class="article">` wrapper on excerpts so any existing `.article` CSS rules (e.g., typography, line-height) apply to search excerpts too.

### Verification
- Rebuilt with `npm run build` and verified no errors.
- Inspected generated HTML with `curl` — the `#search-results` wrapper now has no card classes, and the JS renders per-result cards with matching classes.
- `npm run dev` confirmed the server starts cleanly.

### Known issues / follow-up
- `hugo server` does not auto-re-run Pagefind on content changes. Stop and re-run `npm run dev` to refresh the index after editing posts.

---

## 2026-06-10 — Fixed search result titles to show post title instead of blog title

### What was changed and why
The search results were showing the full HTML `<title>` tag text (`Post Title | Shami's Blog`) instead of just the post title. The `<title>` tag includes the site name suffix (` | Shami's Blog`), which was bleeding into the search result card titles.

### Files touched
- **themes/shami.blog/layouts/_default/single.html** — Added `data-pagefind-meta="post_title"` to the `<h2>` element so Pagefind indexes the clean post title as a separate metadata field
- **themes/shami.blog/layouts/_default/baseof.html** — Updated the search results JS to:
  1. Prefer `data.meta.post_title` (the clean title from the h2) over `data.meta.title` (the `<title>` tag)
  2. Fall back to stripping ` | Shami's Blog` from `data.meta.title` as a safety net

### Decisions made with rationale
- Added `data-pagefind-meta` on the h2 element because the `<title>` tag is controlled by the head template and includes the site name suffix. Pagefind's native metadata extraction can't distinguish between the two.
- The JS fallback regex strip ensures that even if `post_title` is unavailable for some reason, the title won't show the site name suffix.

### Verification
- Rebuilt with `npm run build`. Pagefind re-indexed 135 pages.
- `grep` confirmed that `data-pagefind-meta="post_title"` appears in the generated post HTML.
- `grep` confirmed the JS uses `data.meta.post_title` with the fallback regex.

### Known issues / follow-up
- `hugo server` does not auto-re-run Pagefind on content changes. Stop and re-run `npm run dev` to refresh the index after editing posts.

---

## 2026-06-10 — Added Pagefind to Cloudflare Pages build pipeline

### What was changed and why
Pagefind was only running locally during development. For production, the Cloudflare Pages build pipeline only ran `hugo`, which meant the `public/pagefind/` search index was never generated on deploy. Added the necessary files and configuration so Pagefind indexes the site during every Cloudflare Pages build.

### Files touched
- **.nvmrc** (new) — Pins Node.js to v20, matching the local development environment. Cloudflare Pages reads this file to select the Node.js version.
- **package.json** — Updated the `build` and `dev` scripts to use `npx pagefind` instead of `pagefind` directly. This ensures the correct binary is resolved regardless of PATH setup.

### Cloudflare Pages dashboard configuration

| Setting | Value |
|---------|-------|
| **Build command** | `npm install && npm run build` |
| **Build output directory** | `public` |

The `npm install` step installs `pagefind` from `devDependencies`. The `npm run build` script runs `hugo && npx pagefind --site public`, so the index is always generated from the freshly built HTML.

### Decisions made with rationale
- Used `npx pagefind` in the build script instead of relying on the binary being in PATH. `npx` resolves the binary from `node_modules/.bin/`, which works consistently across local dev and Cloudflare Pages.
- Created `.nvmrc` instead of relying on the Cloudflare Pages default Node.js version. This ensures the local and CI environments use the same Node.js version.
- Kept the build output directory as `public` (Hugo's default) so Cloudflare Pages serves the built site correctly.

### Verification
- Rebuilt locally with `npm run build` and confirmed `public/pagefind/` is generated correctly.
- Verified the `npx pagefind` command resolves and runs the locally installed Pagefind v1.5.2.

### Known issues / follow-up
- The Cloudflare Pages dashboard build command must be manually updated to `npm install && npm run build` if it was previously set to just `hugo`.

---

## 2026-06-10 — Excluded Chroma line numbers from Pagefind index

### What was changed and why
Hugo's Chroma syntax highlighter with `lineNos = true` generates inline line numbers as `<span>` elements with `user-select:none` inline styles. These line numbers (e.g., "1", "2", "3") were being indexed by Pagefind as searchable words, polluting the search index with irrelevant numeric terms. The user wanted the code content to remain searchable but the line numbers to be ignored.

### Files touched
- **package.json** — Added `--exclude-selectors '[style*="user-select:none"]'` to both the `build` and `dev` scripts. This tells Pagefind to skip any element whose inline style contains `user-select:none` during indexing.

### Decisions made with rationale
- Used `--exclude-selectors` (a Pagefind CLI option) instead of `data-pagefind-ignore` attributes. This is because Hugo generates the line number HTML with inline styles (`noClasses = true` means no CSS classes to target), so there's no clean way to add attributes to the generated spans without a custom render hook.
- The selector `[style*="user-select:none"]` is safe because the site only uses `user-select:none` in Chroma line number spans. Verified via `grep` that no other elements on the site use this inline style.
- The code content itself is still indexed because the code text lives in sibling `<span>` elements that do NOT have `user-select:none`.

### Verification
- Rebuilt with `npm run build`. Pagefind reported `Indexed 6044 words` (down from `6839` before the fix), confirming that line numbers were removed from the index.
- `grep` confirmed that `user-select:none` only appears in Chroma line number spans across the entire site.
- Inspected a Pagefind fragment file and confirmed that code content (e.g., `chainloader (hd1)+1`) is still present without the line numbers interleaved.

### Known issues / follow-up
- The Cloudflare Pages dashboard build command must be manually updated to `npm install && npm run build` if it was previously set to just `hugo`.

---

## 2026-06-10 — Improved search responsiveness and result timing

### What was changed and why
The search felt sluggish because the debounce was 200ms and there was no guard against stale results. When a user typed quickly, an older search could overwrite a newer one. Also, the user wanted the posts to stay visible until results were actually fetched, and "No results found" to only appear after the search completes.

### Files touched
- **themes/shami.blog/layouts/_default/baseof.html** — Updated the search JS module:
  1. Reduced debounce from `200ms` to `100ms` for faster response
  2. Added a `currentSearch` counter to discard stale results when a newer search is triggered
  3. Simplified the no-results logic so it only hides posts and shows "No results found" after `debouncedSearch` actually completes
  4. Kept the main content visible during the search, only hiding it after results are ready

### Decisions made with rationale
- Lowered debounce to `100ms` because Pagefind is fast enough to handle more frequent queries without feeling laggy.
- Added a `currentSearch` race guard because `debouncedSearch` returns a Promise and rapid typing could cause out-of-order results to render.
- Combined the `!result || !result.results || result.results.length === 0` checks into a single condition to avoid duplicated code.

### Verification
- Rebuilt with `npm run build` and confirmed no errors.
- Inspected the generated JS in `public/index.html` to confirm `debouncedSearch(query, {}, 100)` and the `currentSearch` guard.

### Known issues / follow-up
- The Cloudflare Pages dashboard build command must be manually updated to `npm install && npm run build` if it was previously set to just `hugo`.
