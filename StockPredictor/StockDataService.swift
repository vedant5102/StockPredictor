//
//  StockDataService.swift
//  StockPredictor
//
//  Created by vedant katre on 11/09/25.
//

import Foundation

class StockDataService {
    
    // Replace "DEMO" with your actual API key from Alpha Vantage
    private let apiKey = "U0A1KKCZ0BUOUX0P"
    
    // This function is now updated to accept a 'fullHistory' parameter.
    func fetchHistoricalData(for symbol: String, fullHistory: Bool = false) async throws -> [HistoricalDataPoint] {
        
        let function = fullHistory ? "TIME_SERIES_DAILY_ADJUSTED" : "TIME_SERIES_DAILY"
        let outputSize = fullHistory ? "full" : "compact"
        
        let urlString = "https://www.alphavantage.co/query?function=\(function)&symbol=\(symbol)&outputsize=\(outputSize)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "URL Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(AlphaVantageResponse.self, from: data)
        
        guard let timeSeries = result.timeSeriesDaily else {
            if let note = result.note {
                throw NSError(domain: "API Error", code: -2, userInfo: [NSLocalizedDescriptionKey: "API Call Limit Reached: \(note)"])
            }
            throw NSError(domain: "API Error", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received."])
        }
        
        // Convert the dictionary into a sorted array of data points
        let dataPoints = timeSeries.map { (dateString, values) -> HistoricalDataPoint? in
            guard let date = DateFormatter.yyyyMMdd.date(from: dateString) else { return nil }
            return HistoricalDataPoint(
                date: date,
                close: Double(values.close) ?? 0.0,
                volume: Int(values.volume) ?? 0
            )
        }.compactMap { $0 }.sorted { $0.date > $1.date }
        
        return dataPoints
    }
}

