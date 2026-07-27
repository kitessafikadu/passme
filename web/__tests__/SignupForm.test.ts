// import { render, screen } from '@testing-library/react'
import "@testing-library/jest-dom";
import HomePage from "../src/app/components/homepage/HomePage";

import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import SignupForm from "../src/app/components/auth/forms/SignupForm";
import { useRegisterMutation } from "@/app/services/authApi";
import { signIn } from "next-auth/react";

// Mock the hooks and dependencies
import { jest } from "@jest/globals";

jest.mock("@/app/services/authApi");
jest.mock("next-auth/react");
jest.mock("next/navigation", () => ({
  useRouter: () => ({
    push: jest.fn(),
  }),
}));
const mockForm: typeof SignupForm = SignupForm;
describe("SignupForm", () => {
  const mockRegister = useRegisterMutation as jest.Mock;
  const mockSignIn = signIn as jest.Mock;

  beforeEach(() => {
    mockRegister.mockReturnValue([jest.fn(), { isLoading: false }]);
    mockSignIn.mockResolvedValue({ error: null });
  });

  it("should validate form inputs and show errors", async () => {
    render(SignupForm);

    // Submit empty form
    fireEvent.click(screen.getByText("GET STARTED"));

    // Check for required field errors
    await waitFor(() => {
      expect(screen.getByText("Name is required")).toBeInTheDocument();
      expect(screen.getByText("Email is required")).toBeInTheDocument();
      expect(screen.getByText("Password is required")).toBeInTheDocument();
    });

    // Test invalid email format
    fireEvent.change(screen.getByPlaceholderText("you@example.com"), {
      target: { value: "invalid-email" },
    });

    fireEvent.click(screen.getByText("GET STARTED"));

    await waitFor(() => {
      expect(screen.getByText("Invalid email format")).toBeInTheDocument();
    });
  });
});

// describe('HomePage', () => {
//   it('renders the homepage with banner and form container', () => {
//     render(<HomePage/>)

//     // Verify main structure
//     expect(screen.getByTestId('homepage')).toBeInTheDocument()
//     expect(screen.getByRole('banner')).toBeInTheDocument()
//     expect(screen.getByTestId('form-container')).toBeInTheDocument()
//   })
// })

import { act } from "react-dom/test-utils";

it("cycles through messages correctly", () => {
  jest.useFakeTimers();
  render(<HomePage />);

  const initialMessage = screen.getByText(/Translate anything, anytime/);
  expect(initialMessage).toBeInTheDocument();

  // Advance timers to trigger message change
  act(() => {
    jest.advanceTimersByTime(3500);
  });

  const secondMessage = screen.getByText(/Another inspiring message/);
  expect(secondMessage).toBeInTheDocument();

  jest.useRealTimers();
});
