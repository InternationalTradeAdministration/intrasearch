require 'match_all_query'

class TradeEventMatchAllQuery
  include MatchAllQuery

  def to_hash
    hash = super
    hash[:sort] = [
      {
        start_date: {
          missing: '_first',
          order: 'asc'
        }
      },
      { source: 'asc' }
    ]
    hash
  end
end
