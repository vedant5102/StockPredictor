//
//  StockViewModel.swift
//  StockPredictor
//
//  Created by vedant katre on 11/09/25.
//

import Foundation
import SwiftUI

// This class is the "brain" of our content view. It handles user input,
// talks to the data and prediction services, and publishes the results to the UI.
@MainActor // This is a crucial property wrapper that ensures all UI updates happen on the main thread.
class StockViewModel: ObservableObject {
    
    // --- Published Properties ---
    // These are the pieces of data our ContentView will listen to.
    // When they change, the UI will automatically update.
    
    @Published var stockSymbol: String = "AAPL"
    @Published var historicalData: [HistoricalDataPoint] = []
    @Published var prediction: PredictionOutput?
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?

    // --- Services ---
    // These are our dependencies for fetching data and making predictions.
    private let dataService = StockDataService()
    private let predictionService = CoreMLPredictionService()

    // --- Public Methods ---
    
    func fetchStockDataAndPredict() {
        // Don't do anything if the symbol is empty.
        guard !stockSymbol.trimmingCharacters(in: .whitespaces).isEmpty else {
            // This UI update is safe because the class is marked @MainActor
            self.errorMessage = "Please enter a stock symbol."
            self.showError = true
            return
        }
        
        // Start the loading process.
        isLoading = true
        prediction = nil // Clear previous prediction
        
        // Use a Task to perform asynchronous work off the main thread.
        Task {
            do {
                // 1. Fetch the latest 100 days of data. This happens on a background thread.
                let fetchedData = try await dataService.fetchHistoricalData(for: stockSymbol)
                
                // 2. Run the prediction model with the fetched data. This also happens on a background thread.
                let predictionResult = try predictionService.predict(with: fetchedData)
                
                // 3. Update our published properties with the results.
                // Because the class is marked @MainActor, these updates are automatically
                // sent back to the main thread, which is safe for the UI.
                self.historicalData = Array(fetchedData.prefix(100))
                self.prediction = predictionResult
                
            } catch {
                // If anything goes wrong, set the error message and trigger the alert.
                self.errorMessage = error.localizedDescription
                self.showError = true
                print("An error occurred: \(error.localizedDescription)")
            }
            
            // Stop the loading process.
            self.isLoading = false
        }
    }
}

