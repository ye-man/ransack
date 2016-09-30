require 'spec_helper'

module Ransack
  describe Configuration do
    it 'yields Ransack on configure' do
      Ransack.configure { |config| expect(config).to eq Ransack }
    end

    it 'adds predicates' do
      Ransack.configure do |config|
        config.add_predicate :test_predicate
      end

      expect(Ransack.predicates).to have_key 'test_predicate'
      expect(Ransack.predicates).to have_key 'test_predicate_any'
      expect(Ransack.predicates).to have_key 'test_predicate_all'
    end

    it 'avoids creating compound predicates if compounds: false' do
      Ransack.configure do |config|
        config.add_predicate(
          :test_predicate_without_compound,
          :compounds => false
          )
      end
      expect(Ransack.predicates)
      .to have_key 'test_predicate_without_compound'
      expect(Ransack.predicates)
      .not_to have_key 'test_predicate_without_compound_any'
      expect(Ransack.predicates)
      .not_to have_key 'test_predicate_without_compound_all'
    end

    it 'should have default value for search key' do
      expect(Ransack.options[:search_key]).to eq :q
    end

    it 'changes default search key parameter' do
      # store original state so we can restore it later
      before = Ransack.options.clone

      Ransack.configure do |config|
        config.search_key = :query
      end

      expect(Ransack.options[:search_key]).to eq :query

      # restore original state so we don't break other tests
      Ransack.options = before
    end

    it 'should have default values for arrows' do
      expect(Ransack.options[:up_arrow]).to eq '&#9660;'
      expect(Ransack.options[:down_arrow]).to eq '&#9650;'
    end

    it 'changes the default value for the up arrow only' do
      before = Ransack.options.clone
      up_value, down_value = 'U+02193', Ransack.options[:down_arrow]

      Ransack.configure { |c| c.custom_arrows = { up_arrow: up_value } }

      expect(Ransack.options[:up_arrow]).to eq up_value
      expect(Ransack.options[:down_arrow]).to eq down_value

      Ransack.options = before
    end

    it 'changes the default value for the down arrow only' do
      before = Ransack.options.clone
      up_value, down_value = Ransack.options[:up_arrow], '<i class="down"></i>'

      Ransack.configure { |c| c.custom_arrows = { down_arrow: down_value } }

      expect(Ransack.options[:up_arrow]).to eq up_value
      expect(Ransack.options[:down_arrow]).to eq down_value

      Ransack.options = before
    end

    it 'changes the default value for both arrows' do
      before = Ransack.options.clone
      up_value, down_value = '<i class="fa fa-long-arrow-up"></i>', 'U+02193'

      Ransack.configure do |config|
        config.custom_arrows = { up_arrow: up_value, down_arrow: down_value }
      end

      expect(Ransack.options[:up_arrow]).to eq up_value
      expect(Ransack.options[:down_arrow]).to eq down_value

      Ransack.options = before
    end

    it 'changes one arrow while respecting the other customized arrow' do
      before = Ransack.options.clone

      Ransack.configure { |c| c.custom_arrows = { up_arrow: 'up' } }
      expect(Ransack.options[:down_arrow]).to eq before[:down_arrow]

      Ransack.configure { |c| c.custom_arrows = { down_arrow: 'DOWN' } }
      expect(Ransack.options[:up_arrow]).to eq 'up'

      Ransack.configure { |c| c.custom_arrows = { up_arrow: '<i>U-Arrow</i>' } }
      expect(Ransack.options[:down_arrow]).to eq 'DOWN'

      Ransack.configure { |c| c.custom_arrows = { down_arrow: 'down arrow-2' } }
      expect(Ransack.options[:up_arrow]).to eq '<i>U-Arrow</i>'

      Ransack.options = before
    end

    it 'adds predicates that take arrays, overriding compounds' do
      Ransack.configure do |config|
        config.add_predicate(
          :test_array_predicate,
          :wants_array => true,
          :compounds => true
          )
      end

      expect(Ransack.predicates['test_array_predicate'].wants_array).to eq true
      expect(Ransack.predicates).not_to have_key 'test_array_predicate_any'
      expect(Ransack.predicates).not_to have_key 'test_array_predicate_all'
    end

    describe '`wants_array` option takes precedence over Arel predicate' do
      it 'implicitly wants an array for in/not in predicates' do
        Ransack.configure do |config|
          config.add_predicate(
            :test_in_predicate,
            :arel_predicate => 'in'
          )
          config.add_predicate(
            :test_not_in_predicate,
            :arel_predicate => 'not_in'
          )
        end

        expect(Ransack.predicates['test_in_predicate'].wants_array)
        .to eq true
        expect(Ransack.predicates['test_not_in_predicate'].wants_array)
        .to eq true
      end

      it 'explicitly does not want array for in/not_in predicates' do
        Ransack.configure do |config|
          config.add_predicate(
            :test_in_predicate_no_array,
            :arel_predicate => 'in',
            :wants_array => false
          )
          config.add_predicate(
            :test_not_in_predicate_no_array,
            :arel_predicate => 'not_in',
            :wants_array => false
          )
        end

        expect(Ransack.predicates['test_in_predicate_no_array'].wants_array)
        .to eq false
        expect(Ransack.predicates['test_not_in_predicate_no_array'].wants_array)
        .to eq false
      end
    end
  end
end
