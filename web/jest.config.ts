import nextJest from "next/jest";
import type { Config } from "jest";

// Create a Next.js-aware Jest config
const createJestConfig = nextJest({
  dir: "./",
});

// Custom Jest config
const customJestConfig: Config = {
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1",
  },
  setupFilesAfterEnv: ["<rootDir>/jest.setup.ts"],
  testEnvironment: "jest-environment-jsdom",
  clearMocks: true,
  collectCoverage: true,
  coverageDirectory: "coverage",
  coverageProvider: "v8",
};

// Export the Jest config
export default createJestConfig(customJestConfig);
