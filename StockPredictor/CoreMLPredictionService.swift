import Foundation
import CoreML

// Defines the output your app will use.
struct PredictionOutput {
    let trend: String
    let confidence: Double
    let forecastPrice: Double
}

class CoreMLPredictionService {
    
    // This line loads your .mlmodel file into a variable.
    private let model = try? StockTrendClassifier(configuration: .init())
    
    func predict(with historicalData: [HistoricalDataPoint]) throws -> PredictionOutput {
        guard let model = model else {
            throw NSError(domain: "ModelError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model is not loaded."])
        }
        
        guard historicalData.count >= 50 else {
            throw NSError(domain: "DataError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Not enough data for prediction (needs 50 days)."])
        }
        
        // --- Feature Engineering in Swift ---
        let latestDataPoint = historicalData[0]
        let sma50 = historicalData.prefix(50).map { $0.close }.reduce(0, +) / 50.0
        let priceChanges = historicalData.prefix(15).map { $0.close }.reversed().diff()
        let gains = priceChanges.filter { $0 > 0 }.reduce(0, +) / 14.0
        let losses = abs(priceChanges.filter { $0 < 0 }.reduce(0, +) / 14.0)
        let rs = (losses == 0) ? gains : gains / losses
        let rsi = 100.0 - (100.0 / (1.0 + rs))

        // --- DEFINITIVE FIX: Prepare the Specific Model Input ---
        // Xcode automatically generates a 'StockTrendClassifierInput' class from your model.
        // We create an instance of this class to pass our features.
        let modelInput = StockTrendClassifierInput(
            Close: latestDataPoint.close,
            Volume: Double(latestDataPoint.volume),
            SMA_50: sma50,
            RSI: rsi
        )
        
        // --- Run the Prediction ---
        print("Making prediction with REAL Model...")
        // We now pass the single, specific input object to the model with the correct 'input' label.
        let prediction = try model.prediction(input: modelInput)
        
        // --- Format and Return the Output ---
        let trend = prediction.Target
        let confidence = prediction.TargetProbability[trend] ?? 0.0
        let forecastPrice = latestDataPoint.close * (trend == "Up" ? 1.02 : 0.98)

        return PredictionOutput(
            trend: trend,
            confidence: confidence,
            forecastPrice: forecastPrice
        )
    }
}

// Helper code to make calculating RSI easier.
extension Array where Element == Double {
    func diff() -> [Double] {
        guard count > 1 else { return [] }
        var differences: [Double] = []
        for i in 1..<count {
            differences.append(self[i] - self[i-1])
        }
        return differences
    }
}

