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
