require 'search'
require 'shared_params'

module TradeEventSharedParams
  extend Grape::API::Helpers

  params :common do
    optional :event_types, type: String
    optional :result_type, type: String, default: 'snippet', values: %w(snippet fields)
    optional :start_date_range, type: Hash do
      optional :from, type: Date, coerce_with: -> (d) { Date.strptime(d, '%Y-%m-%d') unless d.blank? }
      optional :to, type: Date, coerce_with: -> (d) { Date.strptime(d, '%Y-%m-%d') unless d.blank? }
      at_least_one_of :from, :to
    end
    optional :states, type: String
  end
end
