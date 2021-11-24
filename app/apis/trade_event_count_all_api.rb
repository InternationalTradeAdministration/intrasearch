require 'trade_event'

class TradeEventCountAllAPI < Grape::API
  get '/trade_events/all/count' do
    TradeEvent.search(search_type: :count)
  end
end
