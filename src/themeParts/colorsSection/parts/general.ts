import type { TColorPalette, TThemeColorMap } from "@/types/colors";

export default function general(palette: TColorPalette): TThemeColorMap {
  const obj: TThemeColorMap = {
    foreground: palette.foreground,
    focusBorder: palette.background,
    "progressBar.background": "#1d426f",
    "selection.background": "#256aa7",
    "scrollbar.shadow": palette.transparent,
    "textLink.foreground": palette.blue,

    "icon.foreground": palette.foreground,

    "checkbox.background": palette.background,
    "checkbox.foreground": palette.foreground,
    "checkbox.border": palette.transparent,

    "dropdown.background": palette.background,
    "dropdown.foreground": palette.foreground,
    "dropdown.border": palette.transparent,

    "settings.headerForeground": palette.foreground,
    "settings.focusedRowBackground": "#ffffff07",

    "walkThrough.embeddedEditorBackground": "#00000050",

    "quickInput.background": palette.BackgroundSecond,
  };
  if (palette.name && palette.name === "shahin") {
    return {
      ...obj,
      "modernPanel.border": palette.gold,
      // activity bar
      "modernActivityBar.background": palette.gold,
      "activityBar.background": palette.gold,

      "modernActivityBarItem.hoverBackground": palette.BackgroundSecond,
      "activityBar.foreground": palette.gray,

      "modernActivityBarItem.activeForeground": palette.gray,

      "activityBar.inactiveForeground": palette.BackgroundSecond,

      "activityBar.activeBackground": palette.BackgroundSecond,
      focusBorder: palette.gold,
      "list.hoverBackground": palette.gold,
      "tab.activeBorderTop": palette.gold,
      "tab.hoverBackground": palette.gold,
      "modernTab.hoverBackground": palette.gold,
    };
  }
  return obj;
}
