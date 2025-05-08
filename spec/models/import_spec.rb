require 'rails_helper'

RSpec.describe Import, type: :model do
  subject(:import) { build(:import) }

  describe '#file' do
    it { should have_one_attached(:file) }
  end

  describe '#merchant' do
    it { should belong_to(:merchant) }
  end

  describe '#status' do
    it 'has a default initial status' do
      expect(import.status).to eq('pending')
    end
  end
end
