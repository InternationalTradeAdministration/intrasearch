require 'trade_event'

class TradeEventCountAPI < Grape::API
  get '/trade_events/count' do
    TradeEvent.search(search_type: :count, sources: 'ITA')
  end
end
