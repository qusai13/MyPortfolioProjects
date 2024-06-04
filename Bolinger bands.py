import yfinance as yf
import plotly.graph_objs as go

# Get  Nasdaq stock data with a 1-hour timeframe
NDAQ = yf.Ticker("NDAQ")
data = NDAQ.history(period="60d", interval="1h")  # Adjust the period as needed

# Calculate the 20-period Simple Moving Average (SMA)
data['SMA'] = data['Close'].rolling(window=20).mean()

# Calculate the 20-period Standard Deviation (SD), to enhance accuracy Instead 
data['SD'] = data['Close'].rolling(window=20).std() 

# Calculate the Upper Bollinger Band (UB) and Lower Bollinger Band (LB)
data['UB'] = data['SMA'] + 2 * data['SD']
data['LB'] = data['SMA'] - 2 * data['SD']

# Calculate buy and sell signals with more conditions for more accurate results , we shift the close point for multiple points In row to confirm buy and sell signals
data['Buy_Signal'] = ((data['Close'] < data['LB']) & (data['Close'].shift(1) < data['LB'].shift(1))).astype(int)
data['Sell_Signal'] = ((data['Close'] > data['UB']) & (data['Close'].shift(1) > data['UB'].shift(1))).astype(int)

#data['Buy_Signal'] = (data['Close'] < data['LB']).astype(int)
#data['Sell_Signal'] = (data['Close'] > data['UB']).astype(int)

# Create a Plotly figure
fig = go.Figure()

# Add the price chart
fig.add_trace(go.Scatter(x=data.index, y=data['Close'], mode='lines', name='Price'))

# Add the Upper Bollinger Band (UB) and shade the area
fig.add_trace(go.Scatter(x=data.index, y=data['UB'], mode='lines', name='Upper Bollinger Band', line=dict(color='red')))
fig.add_trace(go.Scatter(x=data.index, y=data['LB'], fill='tonexty', mode='lines', name='Lower Bollinger Band', line=dict(color='green')))

# Add the Middle Bollinger Band (MA)
fig.add_trace(go.Scatter(x=data.index, y=data['SMA'], mode='lines', name='Middle Bollinger Band', line=dict(color='blue')))

# Add buy signals

for index, row in data[data['Buy_Signal'] == 1].iterrows():
    fig.add_annotation(x=index, y=row['Close'], text='Buy', showarrow=True, arrowhead=1, ax=20, ay=-30, bgcolor='green', font=dict(color='white'))

# Add sell signals
for index, row in data[data['Sell_Signal'] == 1].iterrows():
    fig.add_annotation(x=index, y=row['Close'], text='Sell', showarrow=True, arrowhead=1, ax=20, ay=-30, bgcolor='red', font=dict(color='white'))

# Customize the chart layout
fig.update_layout(title='Nasdaq Indice Price with Bollinger Bands and Buy/Sell Signals',
                  xaxis_title='Date',
                  yaxis_title='Price',
                  showlegend=True)

# Show the chart
fig.show()
