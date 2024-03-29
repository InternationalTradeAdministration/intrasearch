require 'shared_params'
require 'trade_event'
require 'trade_event_shared_params'

class TradeEventSearchAPI < Grape::API
  helpers SharedParams, TradeEventSharedParams

  params do
    use :full_text_search_with_countries_and_industries,
        :pagination,
        :common
    at_least_one_of :countries,
                    :event_types,
                    :industries,
                    :q,
                    :states,
                    :start_date_range
  end

  get '/trade_events/search' do
    TradeEvent.search declared(params, include_missing: false).merge(sources: 'ITA')
  end
end
