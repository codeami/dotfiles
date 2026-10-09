// The header owns the toggle; the theme module owns what is saved.
export function renderHeader(toggle: () => void): string {
  return `<header><button id="theme-toggle">Dark mode</button></header>`;
}
export const WORKSPACE_LABEL = 'Your workspace';
