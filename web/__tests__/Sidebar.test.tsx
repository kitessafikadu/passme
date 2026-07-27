import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import Sidebar from "../src/app/components/sidebar/Sidebar";
import { useRouter } from "next/navigation";
import { signOut } from "next-auth/react";
import {
  useGetFlightsQuery,
  useDeleteFlightMutation,
} from "../src/app/services/flightsApi";
import { useGetProfileQuery } from "../src/app/services/profileApi";

// Mock next-auth and next/navigation
jest.mock("next-auth/react", () => ({
  signOut: jest.fn(),
}));

jest.mock("next/navigation", () => ({
  useRouter: jest.fn(),
}));

// Mock API hooks
jest.mock("../src/app/services/flightsApi", () => ({
  useGetFlightsQuery: jest.fn(),
  useDeleteFlightMutation: jest.fn(),
}));

jest.mock("../src/app/services/profileApi", () => ({
  useGetProfileQuery: jest.fn(),
}));

// Mock image imports
jest.mock("next/image", () => ({
  __esModule: true,
  default: (props: any) => <img {...props} />,
}));

// Mock child components
jest.mock("../src/app/components/modals/ChangePasswordModal", () => ({
  __esModule: true,
  default: () => <div data-testid="change-password-modal" />,
}));

jest.mock("../src/app/components/modals/ChangeUsernameModal", () => ({
  __esModule: true,
  default: () => <div data-testid="change-username-modal" />,
}));

describe("Sidebar Component", () => {
  const mockPush = jest.fn();
  const mockSignOut = signOut as jest.Mock;
  const mockUseRouter = useRouter as jest.Mock;

  const mockFlights = [
    {
      id: "1",
      title: "Flight to Paris",
      from_country: "USA",
      to_country: "France",
      date: "2023-12-25",
    },
    {
      id: "2",
      title: "Business Trip",
      from_country: "UK",
      to_country: "Germany",
      date: "2023-11-15",
    },
  ];

  const mockProfile = {
    username: "testuser",
    email: "test@example.com",
    about: "Test user profile",
  };

  beforeEach(() => {
    mockUseRouter.mockReturnValue({
      push: mockPush,
    });
    mockSignOut.mockResolvedValue({});

    (useGetFlightsQuery as jest.Mock).mockReturnValue({
      data: mockFlights,
      isLoading: false,
    });

    (useDeleteFlightMutation as jest.Mock).mockReturnValue([
      jest.fn().mockResolvedValue({}),
      { isLoading: false },
    ]);

    (useGetProfileQuery as jest.Mock).mockReturnValue({
      data: mockProfile,
      isLoading: false,
      error: null,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("renders correctly with flights", () => {
    render(<Sidebar />);

    expect(screen.getByText("New chat")).toBeInTheDocument();
    expect(screen.getByText("Flight to Paris")).toBeInTheDocument();
    expect(screen.getByText("Business Trip")).toBeInTheDocument();
  });

  it("renders empty state when no flights", () => {
    (useGetFlightsQuery as jest.Mock).mockReturnValue({
      data: [],
      isLoading: false,
    });

    render(<Sidebar />);

    expect(screen.getByText("No Flight Details Yet")).toBeInTheDocument();
    expect(
      screen.getByText(/Start by adding your travel info/i)
    ).toBeInTheDocument();
  });

  it("shows loading state when flights are loading", () => {
    (useGetFlightsQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    render(<Sidebar />);

    expect(screen.queryByText("No Flight Details Yet")).not.toBeInTheDocument();
    expect(screen.queryByText("Flight to Paris")).not.toBeInTheDocument();
  });

  it("handles flight selection", () => {
    render(<Sidebar />);

    fireEvent.click(screen.getByText("Flight to Paris"));
    expect(mockPush).toHaveBeenCalledWith("/dashboard/flight/1");
  });

  it("handles new chat button click", () => {
    render(<Sidebar />);

    fireEvent.click(screen.getByText("New chat"));
    expect(mockPush).toHaveBeenCalledWith("/dashboard/newflight");
  });

  // it("handles flight deletion", async () => {
  //   const mockDeleteFlight = jest.fn().mockResolvedValue({});
  //   (useDeleteFlightMutation as jest.Mock).mockReturnValue([
  //     mockDeleteFlight,
  //     { isLoading: false },
  //   ]);

  //   render(<Sidebar />);

  //   const deleteButtons = screen.getAllByLabelText("Delete flight");
  //   fireEvent.click(deleteButtons[0]);

  //   await waitFor(() => {
  //     expect(mockDeleteFlight).toHaveBeenCalledWith("1");
  //   });
  // });

  it("handles logout", async () => {
    render(<Sidebar />);

    fireEvent.click(screen.getByText("Log out"));

    await waitFor(() => {
      expect(mockSignOut).toHaveBeenCalledWith({ redirect: false });
      expect(mockPush).toHaveBeenCalledWith("/home");
    });
  });

  it("toggles account modal", () => {
    render(<Sidebar />);

    fireEvent.click(screen.getByText("My account"));
    expect(screen.getByText(mockProfile.username)).toBeInTheDocument();

    fireEvent.click(screen.getByLabelText("Close"));
    expect(screen.queryByText(mockProfile.username)).not.toBeInTheDocument();
  });

  // it("opens change password modal", () => {
  //   render(<Sidebar />);

  //   fireEvent.click(screen.getByText("My account"));
  //   fireEvent.click(screen.getAllByRole("button", { name: /Edit/i })[0]);

  //   expect(screen.getByTestId("change-password-modal")).toBeInTheDocument();
  // });

  // it("opens change username modal", () => {
  //   render(<Sidebar />);

  //   fireEvent.click(screen.getByText("My account"));
  //   fireEvent.click(screen.getAllByRole("button", { name: /Edit/i })[1]);

  //   expect(screen.getByTestId("change-username-modal")).toBeInTheDocument();
  // });

  // it("handles mobile view and sidebar toggle", () => {
  //   global.innerWidth = 500;
  //   global.dispatchEvent(new Event("resize"));

  //   render(<Sidebar />);

  //   expect(screen.queryByText("New chat")).not.toBeInTheDocument();

  //   const toggleButton = screen.getByLabelText("Open sidebar");
  //   fireEvent.click(toggleButton);

  //   expect(screen.getByText("New chat")).toBeInTheDocument();

  //   const closeButton = screen.getByLabelText("Close sidebar");
  //   fireEvent.click(closeButton);

  //   expect(screen.queryByText("New chat")).not.toBeInTheDocument();
  // });

  // it("handles profile loading state", async () => {
  //   (useGetProfileQuery as jest.Mock).mockReturnValue({
  //     data: undefined,
  //     isLoading: true,
  //     error: null,
  //   });

  //   render(<Sidebar />);

  //   fireEvent.click(screen.getByText("My account"));

  //   await waitFor(() => {
  //     expect(screen.getByText("Loading...")).toBeInTheDocument();
  //   });
  // });

  it("handles profile error state", () => {
    (useGetProfileQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: false,
      error: { status: 401, data: "Unauthorized" },
    });

    render(<Sidebar />);

    expect(screen.getByText("New chat")).toBeInTheDocument();
  });
});
