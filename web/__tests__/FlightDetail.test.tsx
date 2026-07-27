import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import FlightDetail from "../src/app/components/flight-detail/flight-detail";
import { useRouter } from "next/navigation";
import { useGetFlightQuery } from "@/app/services/flightsApi";

// Mock next/navigation
jest.mock("next/navigation", () => ({
  useRouter: jest.fn(),
}));

// Mock flights API
jest.mock("@/app/services/flightsApi", () => ({
  useGetFlightQuery: jest.fn(),
}));

// Mock next/image with proper TypeScript typing
jest.mock("next/image", () => {
  const React = require("react");
  return {
    __esModule: true,
    default: (props: {
      src: string;
      alt: string;
      width?: number;
      height?: number;
      className?: string;
      priority?: boolean;
    }) => (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={props.src}
        alt={props.alt}
        width={props.width}
        height={props.height}
        className={props.className}
        data-priority={props.priority?.toString()}
      />
    ),
  };
});

describe("FlightDetail Component", () => {
  const mockPush = jest.fn();
  const mockUseRouter = useRouter as jest.Mock;
  const mockUseGetFlightQuery = useGetFlightQuery as jest.Mock;

  const mockFlightData = {
    id: "123",
    date: "2023-12-25T00:00:00.000Z",
    qa: [
      {
        question: "What documents do I need for my flight?",
        answer: "You need your passport and boarding pass.",
      },
      {
        question: "What time should I arrive at the airport?",
        answer: "At least 2 hours before departure.",
      },
    ],
  };

  beforeEach(() => {
    mockUseRouter.mockReturnValue({
      push: mockPush,
    });

    mockUseGetFlightQuery.mockReturnValue({
      data: mockFlightData,
      isLoading: false,
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("renders loading state when data is loading", () => {
    mockUseGetFlightQuery.mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    render(<FlightDetail flightId="123" />);

    expect(screen.getByText("Loading ...")).toBeInTheDocument();
    expect(screen.getByAltText("A2SV Translator Banner")).toBeInTheDocument();
  });

  it("renders flight details when data is loaded", () => {
    render(<FlightDetail flightId="123" />);

    // Verify banner
    const banner = screen.getByAltText("A2SV Translator Banner");
    expect(banner).toBeInTheDocument();

    // Verify date
    expect(screen.getByText("Your date of flight")).toBeInTheDocument();
    expect(screen.getByText("December 25, 2023")).toBeInTheDocument();

    // Verify conversation
    expect(
      screen.getByText("What documents do I need for my flight?")
    ).toBeInTheDocument();
    expect(
      screen.getByText("You need your passport and boarding pass.")
    ).toBeInTheDocument();
    expect(
      screen.getByText("What time should I arrive at the airport?")
    ).toBeInTheDocument();
    expect(
      screen.getByText("At least 2 hours before departure.")
    ).toBeInTheDocument();

    // Verify button
    expect(screen.getByText("Use Chat")).toBeInTheDocument();
  });

  it("handles empty conversation state", () => {
    mockUseGetFlightQuery.mockReturnValue({
      data: { ...mockFlightData, qa: [] },
      isLoading: false,
    });

    render(<FlightDetail flightId="123" />);

    expect(screen.queryByText("Question:")).not.toBeInTheDocument();
    expect(screen.queryByText("Answer:")).not.toBeInTheDocument();
    expect(screen.getByText("Use Chat")).toBeInTheDocument();
  });

  it('navigates to chat when "Use Chat" button is clicked', () => {
    render(<FlightDetail flightId="123" />);

    fireEvent.click(screen.getByText("Use Chat"));
    expect(mockPush).toHaveBeenCalledWith("/dashboard/chat?flightId=123");
  });

  //   it("renders questions without answers correctly", () => {
  //     const mockDataWithUnanswered = {
  //       ...mockFlightData,
  //       qa: [
  //         ...mockFlightData.qa,
  //         { question: "Unanswered question", answer: null },
  //       ],
  //     };

  //     mockUseGetFlightQuery.mockReturnValue({
  //       data: mockDataWithUnanswered,
  //       isLoading: false,
  //     });

  //     render(<FlightDetail flightId="123" />);

  //     expect(screen.getByText("Unanswered question")).toBeInTheDocument();
  //     expect(
  //       screen.queryByText("Answer:", { selector: "span" })
  //     ).not.toBeInTheDocument();
  //   });

  it("matches snapshot when loading", () => {
    mockUseGetFlightQuery.mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    const { asFragment } = render(<FlightDetail flightId="123" />);
    expect(asFragment()).toMatchSnapshot();
  });

  it("matches snapshot with data", () => {
    const { asFragment } = render(<FlightDetail flightId="123" />);
    expect(asFragment()).toMatchSnapshot();
  });
});
