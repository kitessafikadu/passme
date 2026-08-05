import "@testing-library/jest-dom";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import SignupForm from "../src/app/components/auth/forms/SignupForm";
import { useRegisterMutation } from "@/app/services/authApi";
import { signIn } from "next-auth/react";

jest.mock("@/app/services/authApi");
jest.mock("next-auth/react");
jest.mock("next/navigation", () => ({
  useRouter: () => ({ push: jest.fn() }),
}));

describe("SignupForm", () => {
  const mockRegister = useRegisterMutation as jest.Mock;
  const mockSignIn = signIn as jest.Mock;

  beforeEach(() => {
    mockRegister.mockReturnValue([jest.fn(), { isLoading: false }]);
    mockSignIn.mockResolvedValue({ error: null } as any);
  });

  it("renders the signup form", () => {
    render(<SignupForm />);
    expect(screen.getByPlaceholderText("John Doe")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("you@example.com")).toBeInTheDocument();
  });

  it("shows required field errors on empty submit", async () => {
    render(<SignupForm />);
    fireEvent.click(screen.getByText("GET STARTED"));

    await waitFor(() => {
      expect(screen.getByText("Name is required")).toBeInTheDocument();
    });
  });

  it("shows invalid email error", async () => {
    render(<SignupForm />);

    fireEvent.change(screen.getByPlaceholderText("John Doe"), {
      target: { value: "Test User" },
    });
    fireEvent.change(screen.getByPlaceholderText("you@example.com"), {
      target: { value: "not-an-email" },
    });
    fireEvent.click(screen.getByText("GET STARTED"));

    await waitFor(() => {
      expect(screen.getByText("Invalid email format")).toBeInTheDocument();
    });
  });
});
