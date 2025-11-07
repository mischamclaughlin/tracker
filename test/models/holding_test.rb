require "test_helper"

describe Holding do
  let(:coin) { coins(:bitcoin) }
  let(:portfolio) { portfolios(:main) }
  let(:price) { prices(:bitcoin_current_price) }
  let(:transaction_buy_bitcoin) { transactions(:buy_bitcoin) }
  let(:transaction_sell_bitcoin) { transactions(:sell_bitcoin) }
  let(:holding_bitcoin_main) { holdings(:main_bitcoin) }

  context "when calling public methods" do
    describe "#to_s" do
      it "returns a string representation of the holding" do
        expected_string = "
        Holding ID: #{holding_bitcoin_main.id},
        Coin: #{holding_bitcoin_main.coin.id},
        Portfolio: #{holding_bitcoin_main.portfolio.id},
        Coin Balance: #{holding_bitcoin_main.coin_balance.to_s('F')}
        ".squish

        assert_equal expected_string, holding_bitcoin_main.to_s
      end
    end
  end

  describe "associations" do
    it "belongs to a coin" do
      assert_equal coin, holding_bitcoin_main.coin
    end

    it "belongs to a portfolio" do
      assert_equal portfolio, holding_bitcoin_main.portfolio
    end
  end

  describe "validations" do
    it "validates uniqueness of coin_id scoped to portfolio_id" do
      duplicate_holding = Holding.new(
        coin_id: holding_bitcoin_main.coin_id,
        portfolio_id: holding_bitcoin_main.portfolio_id,
        coin_balance: 1.0
      )
      refute duplicate_holding.valid?
      assert_includes duplicate_holding.errors[:coin_id], "has already been taken"
    end

    it "validates presence and numericality of coin_balance" do
      invalid_holding = Holding.new(
        coin_id: coin.id,
        portfolio_id: portfolio.id,
        coin_balance: -5.0
      )
      refute invalid_holding.valid?
      assert_includes invalid_holding.errors[:coin_balance], "must be greater than or equal to 0"
    end
  end
end
