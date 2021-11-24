require 'shared_params'
require 'trade_event'
require 'trade_event_shared_params'

class TradeEventSearchAllAPI < Grape::API
  helpers SharedParams, TradeEventSharedParams

  params do
    use :full_text_search_with_countries_and_industries,
        :pagination,
        :common
    optional :sources, type: String
    at_least_one_of :countries,
                    :event_types,
                    :industries,
                    :q,
                    :sources,
                    :states,
                    :start_date_range
  end

  get '/trade_events/all/search' do
    TradeEvent.search declared(params, include_missing: false)
  end
end
