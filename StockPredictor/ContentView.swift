import SwiftUI
import Charts

// This is the main user interface for your app.
struct ContentView: View {
    // @StateObject ensures our ViewModel lives through view updates.
    @StateObject private var viewModel = StockViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // -- Header --
                Text("On-Device AI Predictor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // -- Input Section --
                HStack {
                    TextField("Enter Stock Symbol (e.g., AAPL)", text: $viewModel.stockSymbol)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        viewModel.fetchStockDataAndPredict()
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                
                // -- Main Content Area --
                if viewModel.isLoading {
                    ProgressView("Fetching Market Data...")
                        .padding(.top, 50)
                } else if let prediction = viewModel.prediction {
                    // Show prediction and chart if data is loaded
                    predictionDetailView(prediction: prediction)
                } else {
                    // Idle state or initial view
                    Text("Enter a stock symbol to get a prediction.")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                }
                
                Spacer() // Pushes content to the top
            }
            .padding(.top)
            .navigationTitle("Stock Predictor")
            .alert("Prediction Error", isPresented: $viewModel.showError, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            })
        }
    }
    
    /// A view for displaying the AI prediction details.
    private func predictionDetailView(prediction: PredictionOutput) -> some View {
        VStack(spacing: 15) {
            Text(viewModel.stockSymbol.uppercased())
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            HStack {
                Text(prediction.trend)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(prediction.trend == "Up" ? .green : .red)
                
                Image(systemName: prediction.trend == "Up" ? "arrow.up.right" : "arrow.down.right")
                    .font(.title2)
                    .foregroundColor(prediction.trend == "Up" ? .green : .red)
            }
            
            predictionStatView(title: "Confidence", value: "\(Int(prediction.confidence * 100))%")
            predictionStatView(title: "Forecast Price", value: String(format: "$%.2f", prediction.forecastPrice))
            
            stockChartView
        }
        .padding()
    }
    
    /// A small view for a single prediction statistic.
    private func predictionStatView(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
    
    /// A view for displaying the historical stock data chart.
    private var stockChartView: some View {
        VStack(alignment: .leading) {
            Text("Historical Prices (Last 100 Days)")
                .font(.headline)
            
            Chart(viewModel.historicalData) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Price", dataPoint.close)
                )
                .foregroundStyle(.blue)
                
                AreaMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Price", dataPoint.close)
                )
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.5), .blue.opacity(0.01)]), startPoint: .top, endPoint: .bottom))
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

