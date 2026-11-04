import ThemeClass from "./themeClass";
import { palettes } from "@/palettes";
import U from "./util/U";
import { colorTokens as colorTokensOriginal } from "./themeParts/tokenColorsSection/readyColorTokensOriginal";
import { colorTokens as colorTokensTest } from "./themeParts/tokenColorsSection/readyColorTokensTest";
import syncThemeContributions from "./util/syncThemeContributions";

function generateName(name: string) {
  const title = name.charAt(0).toUpperCase() + name.slice(1);
  return {
    name: `Sham ${title}`,
    fileName: `sham-${name.toLowerCase()}-theme`,
  };
}

const themes = [
  { name: "shahin", palette: palettes.shahin },
  { name: "shahin2", palette: palettes.shahin, tokenColors: colorTokensOriginal },
  { name: "shift", palette: palettes.base, tokenColors: colorTokensOriginal },
  { name: "darko", palette: palettes.darko, tokenColors: colorTokensOriginal },
  { name: "vali", palette: palettes.base },
  { name: "glass", palette: palettes.glass, tokenColors: colorTokensTest },
  { name: "glass2", palette: palettes.glass2, tokenColors: colorTokensOriginal },
  { name: "test", palette: palettes.test, tokenColors: colorTokensTest },
];

const themeContributions = themes.map(({ name, palette, tokenColors }) => {
  const metadata = generateName(name);
  const theme = new ThemeClass(palette, tokenColors);
  U.writeThemeToJson(theme.themeResult(metadata.name), metadata.fileName);

  return {
    label: metadata.name,
    uiTheme: "vs-dark" as const,
    path: `./themes/${metadata.fileName}.json`,
  };
});

syncThemeContributions(themeContributions);
