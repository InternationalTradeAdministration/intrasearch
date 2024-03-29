require 'legacy/trade_event_find_by_id_api'
require 'trade_event_count_all_api'
require 'trade_event_count_api'
require 'trade_event_find_by_id_api'
require 'trade_event_search_all_api'
require 'trade_event_search_api'

class TradeEventsAPI < Grape::API
  version 'v1'

  mount TradeEventCountAllAPI
  mount TradeEventCountAPI
  mount TradeEventSearchAllAPI
  mount TradeEventSearchAPI
  mount Legacy::TradeEventFindByIdAPI

  version 'v2'
  mount TradeEventFindByIdAPI
end
