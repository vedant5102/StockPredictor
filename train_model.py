import yfinance as yf
import pandas as pd
import os

print("--- AI Model Training Data Preparation Script ---")

def download_data(ticker, period="5y"):
    print(f"Downloading 5 years of stock data for {ticker} from Yahoo Finance...")
    data = yf.download(ticker, period=period, auto_adjust=True, progress=False)
    print("Data download complete.")
    return data

def create_features_and_save_csv(df, filename="stock_training_data.csv"):
    print("Creating features: 50-day SMA and 14-day RSI...")
    df['SMA_50'] = df['Close'].rolling(window=50).mean()
    
    delta = df['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    rs = gain / loss
    df['RSI'] = 100 - (100 / (1 + rs))
    
    df['Target'] = (df['Close'].shift(-5) > df['Close']).astype(int)
    
    df.dropna(inplace=True)
    
    df['Target'] = df['Target'].map({0: 'Down', 1: 'Up'})
    
    training_df = df[['Close', 'Volume', 'SMA_50', 'RSI', 'Target']]
    
    print(f"Saving training data to {filename}...")
    # THE ONLY CHANGE IS HERE: We now save as a CSV file.
    training_df.to_csv(filename, index=False)
    
    print(f"✅ Successfully created training data file: {filename}")
    return filename

def prepare_data_for_training(ticker="AAPL"):
    data = download_data(ticker)
    create_features_and_save_csv(data)
    print("--- Data preparation complete! ---")

if __name__ == "__main__":
    prepare_data_for_training(ticker="AAPL")

