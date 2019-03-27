require 'support/elastic_model_shared_contexts'

RSpec.describe TradeEvent::Extra do
  describe '.create' do
    include_context 'elastic models',
                    described_class

    context 'when the attribute values are blank' do
      subject do
        described_class.create id: '100',
                               md_description: '  ',
                               html_description: '  '
      end

      it { is_expected.to have_attributes(md_description: nil,
                                          html_description: nil) }
    end

    context 'when the attribute values contain newline' do
      subject do
        described_class.create id: '100',
                               md_description: " foo\nbar ",
                               html_description: " bar\nfoo "
      end

      it { is_expected.to have_attributes(html_description: " bar\nfoo ",
                                          md_description: " foo\nbar ") }
    end
  end

  describe '.ids' do
    include_context 'elastic models',
                    described_class

    it 'returns document ids' do
      expect(described_class.ids).to include('ITA-36282', 'SBA-730226ea901d6c4bf7e4e4f5ef12ebec8c482a2b')
    end
  end

  describe '.prune_obsolete_documents' do
    context 'when parent_ids do not include existing Extra ids' do
      include_context 'elastic models',
                      described_class

      it 'deletes Extra documents' do
        parent_ids = %w(1)
        described_class.prune_obsolete_documents(parent_ids)

        expect(described_class.count).to be_zero
      end
    end

    context 'when parent_ids include existing Extra ids' do
      include_context 'elastic models',
                      described_class

      it 'preserves Extra documents with ids included in parent_ids' do
        parent_ids = %w(ITA-36282).freeze
        described_class.prune_obsolete_documents(parent_ids)

        expect(described_class.all.map(&:id)).to eq(parent_ids)
      end
    end
  end
end
