# Design System Strategy: High-End Editorial

## 1. Overview & Creative North Star
This design system is built to transform a functional developer utility into a premium digital experience. Our **Creative North Star** is **"The Precision Curator."**

We move beyond the "generic SaaS" look by embracing a layout strategy inspired by modern macOS interfaces and high-end editorial print. The aesthetic is defined by extreme clarity, "breathing" whitespace, and intentional depth. Instead of traditional grids that feel boxed in, we use asymmetrical groupings and overlapping "glass" layers to create a sense of software that is both powerful and light.

The goal is a "Native+" feel—respecting the logic of macOS while elevating it through sophisticated tonal layering and superior typographic hierarchy.

---

## 2. Colors: Tonal Architecture
The palette avoids harsh contrasts in favor of a sophisticated, monochromatic foundation punctuated by high-energy blue accents.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning or layout containment. Structural boundaries must be defined solely through background color shifts.
*   **Example:** A `surface-container-low` section sitting on a `background` provides all the edge definition required.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-transparent materials. Use the `surface-container` tiers to create nested importance:
*   **Base Layer:** `surface` (#faf8ff) for the main canvas.
*   **Secondary Content:** `surface-container-low` (#f2f3ff) for secondary sections.
*   **Actionable Cards:** `surface-container-lowest` (#ffffff) to provide a "pop" of brightness.
*   **Persistent UI Elements:** `surface-container-high` (#e2e7ff) for toolbars or navigation overlays.

### The "Glass & Gradient" Rule
To achieve the macOS "Native+" aesthetic, use Glassmorphism for floating elements (e.g., Modals, Tooltips). Apply `surface-variant` with a `backdrop-blur` of 24px and 40% opacity.
*   **Signature Textures:** For primary CTAs, do not use flat fills. Apply a subtle linear gradient from `primary` (#0058be) to `primary_container` (#2170e4) at a 135° angle to add "visual soul" and professional depth.

---

## 3. Typography: The Editorial Voice
We utilize a dual-typeface system to balance technical precision with human-centric authority.

*   **Display & Headlines (Manrope):** Chosen for its geometric purity and modern proportions. Use `display-lg` (3.5rem) with tight letter-spacing (-0.02em) for hero moments to establish immediate authority.
*   **Body & UI (Inter):** The industry standard for legibility. Inter is used for all functional text, ensuring a "developer-friendly" environment that feels native to the tools they use daily.
*   **Hierarchy as Identity:** By maximizing the scale difference between a `headline-lg` and `body-md`, we create an editorial rhythm that guides the eye naturally through the technical features without overwhelming the user.

---

## 4. Elevation & Depth
Depth in this system is a product of light and material, not shadows.

### The Layering Principle
Achieve lift by "stacking" surface tiers. A `surface-container-lowest` card placed on a `surface-container-low` background creates a natural, soft lift that feels integrated into the environment.

### Ambient Shadows
Shadows should be rare and invisible. When a floating state is required (e.g., a dragged element or a main dropdown):
*   **Blur:** 40px - 60px.
*   **Opacity:** 4% - 8% of the `on_surface` color.
*   **Color Tinting:** Never use pure black. Tint the shadow with a hint of the background color to mimic natural ambient occlusion.

### The "Ghost Border" Fallback
If an element lacks contrast against its background (common in Accessibility edge cases), use a **Ghost Border**:
*   **Token:** `outline_variant` (#c2c6d6) at 15% opacity.
*   **Constraint:** 100% opaque borders are strictly forbidden.

---

## 5. Components

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary_container`), `md` (0.75rem) corner radius. Text is `label-md` in `on_primary`.
*   **Secondary:** `surface-container-highest` background with `primary` text. No border.
*   **Tertiary/Ghost:** No background. `primary` text. High-contrast hover state using `surface-container-low`.

### Cards & Lists
*   **Execution:** Forbid the use of divider lines. Separate list items using `spacing-4` (1.4rem) or subtle background shifts.
*   **Glass Cards:** Use `surface_variant` at 40% opacity with a 24px backdrop blur for high-end feature showcases.

### Input Fields
*   **Soft Focus:** Default state uses `surface-container-low`. On focus, the background shifts to `surface-container-lowest` with a 2px `primary` ghost-border (20% opacity).

### Chips (System Metadata)
*   **Visual Style:** Pill-shaped (`full` roundedness). Use `surface-container-high` for the background with `on_surface_variant` for text. These should feel like metadata "tags" found in a file inspector.

---

## 6. Do’s and Don’ts

### Do
*   **Use Generous Whitespace:** If you think there is enough space, add 20% more. Use `spacing-16` (5.5rem) and `spacing-20` (7rem) to separate major content blocks.
*   **Embrace Asymmetry:** Align text to the left while keeping visual assets offset to the right to create a dynamic, editorial feel.
*   **Prioritize Type Scale:** Let the size of the font communicate the importance, not the weight or color.

### Don’t
*   **Don't Use Dividers:** Never use a `<hr>` or 1px border to separate content. Use the Spacing Scale.
*   **Don't Use Pure Black:** Ensure all "dark" text uses `on_surface` (#131b2e) to maintain a soft, premium tone.
*   **Don't Over-Shadow:** If an element isn't "floating" in the user's z-space (like a modal), it shouldn't have a shadow. Use tonal shifts instead.
