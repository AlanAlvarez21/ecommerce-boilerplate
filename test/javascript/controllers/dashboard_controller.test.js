import { Application } from "@hotwired/stimulus";
import DashboardController from "../../../app/javascript/controllers/dashboard_controller";

// Mock Chart.js
const mockChart = jest.fn();
jest.mock('chart.js', () => ({
  Chart: mockChart,
  registerables: []
}));

describe("DashboardController", () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up DOM with Chart.js canvas element
    document.body.innerHTML = `
      <div data-controller="dashboard" 
           data-dashboard-revenue-value='[["Monday", 15000], ["Tuesday", 25000], ["Wednesday", 18000]]'>
        <canvas id="revenueChart"></canvas>
      </div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("dashboard", DashboardController);
    
    element = document.querySelector('[data-controller="dashboard"]');
    controller = application.getControllerForElementAndIdentifier(element, "dashboard");
    
    // Clear mocks
    jest.clearAllMocks();
  });

  afterEach(() => {
    application.stop();
  });

  describe("connect", () => {
    it("creates a Chart.js line chart", () => {
      controller.connect();
      
      expect(mockChart).toHaveBeenCalledTimes(1);
    });

    it("uses canvas element with id 'revenueChart'", () => {
      const canvas = document.getElementById('revenueChart');
      
      controller.connect();
      
      expect(mockChart).toHaveBeenCalledWith(
        canvas,
        expect.any(Object)
      );
    });

    it("processes revenue data correctly", () => {
      controller.connect();
      
      const chartConfig = mockChart.mock.calls[0][1];
      
      // Data should be divided by 100 (converting cents to dollars)
      expect(chartConfig.data.data).toEqual([150.0, 250.0, 180.0]);
      
      // Labels should be the day names
      expect(chartConfig.data.labels).toEqual(["Monday", "Tuesday", "Wednesday"]);
    });

    it("configures chart as line type", () => {
      controller.connect();
      
      const chartConfig = mockChart.mock.calls[0][1];
      expect(chartConfig.type).toBe('line');
    });

    it("configures chart with correct dataset", () => {
      controller.connect();
      
      const chartConfig = mockChart.mock.calls[0][1];
      const dataset = chartConfig.data.datasets[0];
      
      expect(dataset.label).toBe('Revenue $');
      expect(dataset.data).toEqual([150.0, 250.0, 180.0]);
      expect(dataset.borderWidth).toBe(3);
      expect(dataset.fill).toBe(true);
    });

    it("configures chart options correctly", () => {
      controller.connect();
      
      const chartConfig = mockChart.mock.calls[0][1];
      const options = chartConfig.options;
      
      // Legend should be hidden
      expect(options.plugins.legend.display).toBe(false);
      
      // X-axis grid should be hidden
      expect(options.scales.x.grid.display).toBe(false);
      
      // Y-axis should begin at zero
      expect(options.scales.y.beginAtZero).toBe(true);
      
      // Y-axis grid color
      expect(options.scales.y.grid.color).toBe("#d4f3ef");
      
      // Y-axis border dash
      expect(options.scales.y.border.dash).toEqual([5, 5]);
    });

    context "with empty revenue data", () => {
      beforeEach(() => {
        element.setAttribute('data-dashboard-revenue-value', '[]');
      });

      it "handles empty data gracefully", () => {
        controller.connect();
        
        const chartConfig = mockChart.mock.calls[0][1];
        expect(chartConfig.data.data).toEqual([]);
        expect(chartConfig.data.labels).toEqual([]);
      });
    });

    context "with single data point", () => {
      beforeEach(() => {
        element.setAttribute('data-dashboard-revenue-value', '[["Friday", 30000]]');
      });

      it "handles single data point", () => {
        controller.connect();
        
        const chartConfig = mockChart.mock.calls[0][1];
        expect(chartConfig.data.data).toEqual([300.0]);
        expect(chartConfig.data.labels).toEqual(["Friday"]);
      });
    });

    context "with zero revenue values", () => {
      beforeEach(() => {
        element.setAttribute('data-dashboard-revenue-value', '[["Monday", 0], ["Tuesday", 0]]');
      });

      it "handles zero values correctly", () => {
        controller.connect();
        
        const chartConfig = mockChart.mock.calls[0][1];
        expect(chartConfig.data.data).toEqual([0.0, 0.0]);
        expect(chartConfig.data.labels).toEqual(["Monday", "Tuesday"]);
      });
    });

    context "when canvas element is missing", () => {
      beforeEach(() => {
        document.getElementById('revenueChart').remove();
      });

      it "handles missing canvas element", () => {
        // This should not throw an error, but Chart.js will receive null
        controller.connect();
        
        expect(mockChart).toHaveBeenCalledWith(
          null,
          expect.any(Object)
        );
      });
    });
  });
});