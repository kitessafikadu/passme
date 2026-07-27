import { dirname } from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";
import js from "@eslint/js";
import jestPlugin from "eslint-plugin-jest";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

export default [
  // Base JS recommendations
  js.configs.recommended,

  // Your existing Next.js config
  ...compat.extends("next/core-web-vitals", "next/typescript"),

  // Jest configuration
  {
    files: ["**/__tests__/**/*.{js,jsx,ts,tsx}"],
    plugins: {
      jest: jestPlugin,
    },
    rules: {
      // Jest-specific rules
      "jest/no-disabled-tests": "warn",
      "jest/no-focused-tests": "error",
      "jest/no-identical-title": "error",
      "jest/prefer-to-have-length": "warn",
      "jest/valid-expect": "error",

      // Allow img elements in tests (for next/image mocking)
      "@next/next/no-img-element": "off",
    },
    languageOptions: {
      globals: {
        jest: true,
        describe: true,
        it: true,
        expect: true,
        beforeEach: true,
        afterEach: true,
      },
    },
  },
];
