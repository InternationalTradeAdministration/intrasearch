require 'support/api_shared_contexts'
require 'support/api_shared_examples'
require 'support/api_spec_helpers'
require 'support/elastic_model_shared_contexts'

RSpec.describe TradeEventSearchAPI, endpoint: '/v1/trade_events/search' do
  include APISpecHelpers

  include_context 'elastic models',
                  Country,
                  TradeEvent::DlTradeEvent,
                  TradeEvent::Extra,
                  TradeEvent::ItaTradeEvent,
                  TradeEvent::SbaTradeEvent,
                  TradeEvent::UstdaTradeEvent,
                  TradeRegion,
                  WorldRegion

  include_context 'API response'

  context 'when searching without a parameter' do
    before { get described_endpoint }

    it_behaves_like 'a bad request response'
  end

  context 'when searching with matching query term in the name' do
    before { get described_endpoint, 'q' => 'event', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 2,
                                           count: 1,
                                           offset: 0,
                                           next_offset: 1)
    end

    it 'returns countries aggregation' do
      expected_countries = [
        { key: 'Taiwan', doc_count: 1 },
        { key: 'United States', doc_count: 1 }
      ]
      expect(parsed_body[:aggregations][:countries]).to eq(expected_countries)
    end

    it 'returns event types aggregation' do
      expected_countries = [
        { key: 'Seminar-Webinar', doc_count: 1 },
        { key: 'Trade Mission', doc_count: 1 }
      ]
      expect(parsed_body[:aggregations][:event_types]).to eq(expected_countries)
    end

    it 'returns industries aggregation' do
      expected_industries = [
        { key: '/Franchising', doc_count: 1 },
        { key: '/Information and Communication Technology', doc_count: 1 },
        { key: '/Information and Communication Technology/eCommerce Industry', doc_count: 1 },
        { key: '/Retail Trade', doc_count: 1 },
        { key: '/Retail Trade/eCommerce Industry', doc_count: 1 }
      ]
      expect(parsed_body[:aggregations][:industries]).to eq(expected_industries)
    end

    it 'returns states aggregation' do
      expected_states = [
        { key: 'CA', doc_count: 1 }
      ]
      expect(parsed_body[:aggregations][:states]).to eq(expected_states)
    end

    it 'returns sources aggregation' do
      expected_sources = [
        { key: 'ITA', doc_count: 2 }
      ]
      expect(parsed_body[:aggregations][:sources]).to eq(expected_sources)
    end

    it 'highlights matching term in the title' do
      expected_first_result = {
        id: 'ITA-36282',
        snippet: '<em>Event</em> 36282 description.',
        title: 'Trade <em>Event</em> 36282',
        url: 'https://example.org/trade_event?id=ITA-36282' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when searching with matching query term in the description' do
    before { get described_endpoint, 'q' => 'panel', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'highlights matching term in the description' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this <em>panel</em> discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when searching with matching query term in the venue' do
    before { get described_endpoint, 'q' => 'virtual', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this panel discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when searching with country name in the query' do
    before { get described_endpoint, 'q' => 'Taiwan', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns snippet, title and URL' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this panel discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when searching with trade region name in the query' do
    before { get described_endpoint, 'q' => 'NAFTA', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns snippet, title and URL' do
      expected_first_result = {
        id: 'ITA-36282',
        snippet: 'Event 36282 description.',
        title: 'Trade Event 36282',
        url: 'https://example.org/trade_event?id=ITA-36282' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when searching with world region name in the query' do
    before { get described_endpoint, 'q' => 'East Asia', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns snippet, title and URL' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this panel discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when filtering with countries' do
    before { get described_endpoint, 'countries' => 'Taiwan', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this panel discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when filtering with event types' do
    before { get described_endpoint, 'event_types' => 'Trade Mission', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36282',
        snippet: 'Event 36282 description.',
        title: 'Trade Event 36282',
        url: 'https://example.org/trade_event?id=ITA-36282' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when filtering with industries' do
    before { get described_endpoint, 'industries' => 'Retail Trade', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36288',
        snippet: 'Participate in this panel discussion to hear private and public sector leaders on their experiences and what it takes to succeed as innovators and business leaders in STEM fields.',
        title: 'Trade Event 36288',
        url: 'https://example.org/trade_event?id=ITA-36288' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when filtering with sources' do
    before { get described_endpoint, 'sources' => 'ITA', 'limit' => 1 }

    it_behaves_like 'a bad request response'
  end

  context 'when filtering with start date range' do
    before { get described_endpoint, 'start_date_range' => { 'from' => '2016-05-15', 'to' => '2016-05-16' }, 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36282',
        snippet: 'Event 36282 description.',
        title: 'Trade Event 36282',
        url: 'https://example.org/trade_event?id=ITA-36282' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when filtering with states' do
    before { get described_endpoint, 'states' => 'CA,NY', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns unhighlighted title and snippet' do
      expected_first_result = {
        id: 'ITA-36282',
        snippet: 'Event 36282 description.',
        title: 'Trade Event 36282',
        url: 'https://example.org/trade_event?id=ITA-36282' }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end

  context 'when paginating with offset and limit' do
    before { get described_endpoint, 'q' => 'event', 'limit' => 2, 'offset' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 2,
                                           count: 1,
                                           offset: 1,
                                           next_offset: nil)
    end
  end

  context 'when result type is detail' do
    before { get described_endpoint, 'q' => 'Event 36282', 'result_type' => 'fields', 'limit' => 1 }

    it_behaves_like 'a successful API response'

    it 'returns metadata' do
      expect(parsed_body[:metadata]).to eq(total: 1,
                                           count: 1,
                                           offset: 0,
                                           next_offset: nil)
    end

    it 'returns fields' do
      expected_first_result = {
        id: 'ITA-36282',
        click_url: 'https://goo.gl/ita1',
        contacts: [
          {
            email: 'John.Doe@example.gov',
            first_name: 'John',
            last_name: 'Doe',
            person_title: 'Commercial Officer',
            phone: '886-2-1111-2222',
            post: 'Taipei'
          },
          {
            email: 'Jane.Doe@example.gov',
            first_name: 'Jane',
            last_name: 'Doe',
            person_title: 'Trade Specialist',
            phone: '82-2-333-4444',
            post: 'Seoul'
          }
        ],
        cost: 4400.0,
        description: '<h1>Event 36282 description.</h1>',
        end_date: '2016-05-24',
        event_type: 'Trade Mission',
        hosted_url: 'https://example.org/trade_event?id=ITA-36282',
        industries: ['Franchising'],
        name: 'Trade Event 36282',
        registration_title: 'Event 36282 title',
        registration_url: 'https://ita.trade.event.example.org/registration/36282',
        source: 'ITA',
        start_date: '2016-05-15',
        url: 'https://ita.trade.event.example.org/event/36282',
        venues: [
          city: 'San Francisco',
          country: 'United States',
          name: 'Moscone Center, San Francisco',
          postal_code: nil,
          state: 'CA',
          street: nil
        ]
      }
      expect(parsed_body[:results].first).to eq(expected_first_result)
    end
  end
end
