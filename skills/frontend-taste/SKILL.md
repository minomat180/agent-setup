---
name: frontend-taste
description: >-
  Anti-slop rules for any UI work: web apps, dashboards, tools, landing pages, components, HTML
  artifacts, in plain HTML/CSS or React, Next.js, Vue, Svelte, Tailwind, shadcn. Use it whenever you
  build, design, redesign, restyle or review a page or component, write UI copy, or when mino says
  something looks generic, templated, "AI-made" or sloppy. Lists the visual and copy tells of
  model-made UI, the moves that replace them, and a screenshot-and-fix loop before calling it done.
---

# Frontend taste

The goal: a UI that looks made for this product by someone who cared, not the average of every
generated page. Slop is what you get when every decision falls back to the most common choice.
Each rule below bans a default and names what to do instead; a ban without a replacement just
breeds the next default.

## 0. Before writing any UI

1. **Existing design system wins.** If the project has tokens, components, a Tailwind config, a
   shadcn theme or a style guide, use it and match the surrounding screens. Do not restyle what
   you were not asked to restyle. Most of this file is for the gaps.
2. **Name what it is** in one line: app screen (dense, used daily), tool/dashboard (data first),
   marketing page (sells one thing), document/report (reads top to bottom). Each has a different
   density and a different job; a dashboard built like a landing page is slop.
3. **Collect the real material:** product name, what it does, real data shape, real screenshots,
   brand colours, logo. Design around the content you have; never invent content to fill a layout.
4. **Write a 3-line direction** before code: who uses it and where; the one primary action per
   screen; the look in concrete terms (type pairing, palette with hex values, radius, density)
   with one sentence on why it fits *this* subject. If the "why" would fit any product, pick again.

## 1. Visual tells (ban the default, do the replacement)

| Default (tell) | Instead |
| --- | --- |
| Purple/indigo/violet accents, indigo-to-pink or blue-to-purple gradients | One accent derived from the brand or subject; neutrals do most of the work. No purple unless the brand is purple. |
| Gradient text on the headline, glowing blobs, aurora backgrounds | Solid ink on a flat or very subtle ground; let type size and weight carry the hierarchy |
| Glassmorphism / backdrop-blur on everything | Opaque surfaces; blur only where something actually overlays content (a sticky header over scroll) |
| Centered hero: pill badge ("✨ New"), huge headline, grey subline, two buttons, screenshot with glow | Show the product or the thing itself first; left-aligned or asymmetric layouts; one primary action |
| Three feature cards, each an icon in a rounded tinted square + title + two lines | Structure follows the content: a real screenshot with annotations, a list, a table, a comparison, a single strong example |
| Emoji as icons or bullets; a Lucide icon on every heading and card | Icons only where they aid scanning (nav, actions, file types); one icon set, one size, one stroke weight. Real brand logos for real products. |
| `rounded-2xl shadow-lg` on every box, cards inside cards | One radius scale, shadows only on things that float (menus, dialogs). Max two levels of containment; separate with space and hairlines before boxes. |
| Coloured left-border callout cards, accent borders everywhere | Use the border colour once, meaningfully (selected, error), not as decoration |
| Stat strip under the hero ("10k+ users · 99.9% uptime · 4.9★") | Only real figures from the brief, inside the sentence they prove |
| Three polished testimonials with avatars and names like Priya, Marcus, Sarah | No testimonials unless real ones are given, word for word |
| Eyebrow label over every section (`FEATURES`, tiny mono caps, "01 / 02 / 03") | A plain heading that names the content; eyebrows at most once if it carries information |
| Bento grid by default | Bento only when the items genuinely differ in importance and size |
| `hover:scale-105`, fade-up-on-scroll on every element, staggered reveals | Small, fast, purposeful motion: 120-200 ms, colour/opacity/2px lifts; nothing waits for scroll to become visible; respect `prefers-reduced-motion` |
| Inter / system font for everything, or the trendy fallback: cream ground + serif + terracotta | Pick type for the subject: a workhorse sans for dense apps, a characterful display face for a brand page; max two families; set a real scale (e.g. 12/14/16/20/24/32/48) and line-heights |
| `text-gray-500` for half the page, low contrast | Two or three text tones total; body text passes WCAG AA; grey is for secondary, not for everything |
| Fake dashboard mockups with random charts and lorem numbers | Real UI of the actual product, or a focused fragment showing the one thing it does, with plausible data that fits the domain |
| Dark mode = black + neon glow | Dark grounds are dark greys with real elevation steps; accents are desaturated slightly |
| Every section the same height, padding and layout | Rhythm follows content: dense where there is a lot, generous where there is one idea |
| Uniform 4-column footer of made-up links | Only links that exist; a short footer is fine |

## 2. Craft the defaults miss

- **Grid and alignment:** one container width, consistent left and right edges; elements align
  to a column grid or to each other. Spacing from one scale (4/8-based), never arbitrary values.
- **Hierarchy:** one clear focal point per screen. Size, weight and colour contrast do the work
  before boxes and borders do.
- **States:** every interactive thing has hover, focus-visible, active, disabled; every data view
  has loading (skeleton matching the layout), empty (says what to do next), error (says what
  happened and how to fix it), and overflow (long names, 0 items, 10 000 items).
- **Density for apps:** tables over card grids for lists of records; tabular numerals for figures;
  right-aligned numbers; compact rows (32-40px) when users scan; sticky headers for long tables.
- **Forms:** visible labels (not placeholder-only), errors under their field, sensible input
  types, the primary button says what happens ("Create invoice", not "Submit").
- **Responsive:** check 1440, 1024, 768, 390. No horizontal scroll, tap targets ~44px on touch,
  stacks read in the right order.
- **Accessibility:** semantic elements, alt text, heading order, focus rings that are visible,
  keyboard reachable, contrast AA.
- **Images:** real photos/screenshots over illustrations; never stock passed off as the product;
  no captions apologising for or describing a picture.

## 3. Copy

Copy is half of what reads as AI-made. Full list with fixes: `references/copy-tells.md`. Short
version:

- **Banned words:** seamless, effortless, elevate, unlock, unleash, empower, supercharge, harness,
  leverage, robust, powerful, cutting-edge, revolutionary, transformative, next-gen, world-class,
  game-changing, delve, tapestry, realm, journey, ecosystem, landscape. Replace each with the fact
  it stands for.
- **Banned shapes:** "X. Y." two-fragment headings on every section; "It's not X, it's Y" and its
  substitutes ("rather than", "without the"); "No X, no Y, no Z" runs; "The result? ..."; the
  ", ensuring ..." rider; "Ready to transform your X?"; "Whether you're A or B"; the quippy closer
  at the end of every paragraph; virtue words about ourselves (honest, thoughtful, simply,
  genuinely).
- **No invented specifics** (fake stats, fake customers, fake anecdotes). Real facts from the brief,
  or a plainer line.
- **Headings name things, buttons are verb + object, microcopy (errors, empty states,
  confirmations) is written, not left stock.** Em dashes sparingly; no exclamation marks in body
  copy; no emoji bullets.
- **Watch the over-correction:** banning "not X but Y" breeds "instead of"; banning hype breeds
  calm virtue words; banning threes breeds pairs. The fix is always a concrete fact.

## 4. The loop (required before saying "done")

1. Build.
2. **Look at it.** Render and screenshot at desktop and phone width with whatever is available
   (T3 preview tools when the request is browser work, `pib`/`pib-chrome`, or headless Chrome:
   `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --screenshot=out.png --window-size=1440,900 file:///abs/path.html`).
   Then read the screenshots. Code that "should look fine" is not checked.
3. **Critique against this file:** go through section 1's left column and section 3 and list every
   tell you can find. Ask: if the product name were swapped, would this page fit any other product?
   If yes, it is slop.
4. Fix, re-shoot, repeat (2-3 rounds max), then report what you checked and what is left.

## 5. Final checklist

- [ ] Follows the project's existing system; nothing restyled unasked
- [ ] Direction written, with a reason specific to this subject
- [ ] No tell from section 1 used as a default (each one present has a reason)
- [ ] One accent, one radius scale, one button style pair, ≤ 2 font families, spacing on a scale
- [ ] All content real or clearly marked placeholder for the user to fill; no fake stats, logos, testimonials
- [ ] States: hover, focus, loading, empty, error
- [ ] Screenshots at desktop and 390 looked at; no overflow, no misalignment
- [ ] Copy free of banned words and shapes; buttons verb + object
- [ ] Contrast AA, keyboard reachable, reduced motion respected

Credit: distilled in part from tasteskill (github.com/Leonxlnx/taste-skill, MIT). Its full kit
(headless-Chrome gate, palette dealers, section library) is aimed only at marketing websites and is
not installed here.
