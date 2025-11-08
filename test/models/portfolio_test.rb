require "test_helper"

describe Portfolio do
  let(:portfolio_main) { portfolios(:main) }
  let(:holding_bitcoin_main) { holdings(:main_bitcoin) }
  let(:holding_ethereum_main) { holdings(:main_ethereum) }
  let(:transaction_buy_bitcoin) { transactions(:buy_bitcoin) }
  let(:transaction_sell_bitcoin) { transactions(:sell_bitcoin) }
  let(:price_bitcoin) { prices(:bitcoin_current_price) }
  let(:price_ethereum) { prices(:ethereum_current_price) }

  context "when calling public methods" do
    describe "#to_s" do
      it "returns a string representation of the portfolio" do
        expected_string = "
        Portfolio ID: #{portfolio_main.id},
        Portfolio Name: #{portfolio_main.portfolio_name},
        Portfolio Description: #{portfolio_main.description},
        Portfolio Created At: #{portfolio_main.created_at.strftime('%d/%m/%Y %H:%M:%S')}
        ".squish

        assert_equal expected_string, portfolio_main.to_s
      end
    end

    describe "#total_coin_balance_for" do
      it "returns the correct coin balance for a given coin" do
        coin = coins(:bitcoin)
        expected_balance = holding_bitcoin_main.coin_balance

        assert_equal expected_balance, portfolio_main.total_coin_balance_for(coin)
      end

      it "returns 0 if there is no holding for the given coin" do
        coin = coins(:ripple)

        assert_equal 0, portfolio_main.total_coin_balance_for(coin)
      end
    end

    describe "#current_value" do
      it "calculates the current value of the portfolio correctly" do
        expected_value = (holding_bitcoin_main.coin_balance * price_bitcoin.price + holding_ethereum_main.coin_balance * price_ethereum.price)

        assert_equal expected_value, portfolio_main.current_value
      end
    end

    describe "#total_fiat_invested" do
      it "calculates the total fiat invested correctly" do
        buys = portfolio_main.transactions.where(action: 'buy').sum(:fiat_amount)
        sells = portfolio_main.transactions.where(action: 'sell').sum(:fiat_amount)
        expected_invested = buys - sells

        assert_equal expected_invested, portfolio_main.total_fiat_invested
      end
    end

    describe "#profit_loss" do
      it "calculates the profit or loss correctly" do
        expected_profit_loss = portfolio_main.current_value - portfolio_main.total_fiat_invested

        assert_equal expected_profit_loss, portfolio_main.profit_loss
      end
    end

    describe "#profit_loss_percentage" do
      it "calculates the profit or loss percentage correctly" do
        total_invested = portfolio_main.total_fiat_invested
        if total_invested.zero?
          expected_percentage = 0
        else
          expected_percentage = (portfolio_main.profit_loss / total_invested * 100).round(2)
        end

        assert_equal expected_percentage, portfolio_main.profit_loss_percentage
      end
    end
  end

  describe "validations" do
    context "when validating presence and uniqueness of portfolio_name" do
      it "is invalid without a portfolio_name" do
        invalid_portfolio = Portfolio.new(description: "Test Description")
        refute invalid_portfolio.valid?
        assert_includes invalid_portfolio.errors[:portfolio_name], "can't be blank"
      end

      it "is invalid with a duplicate portfolio_name" do
        duplicate_portfolio = Portfolio.new(
          portfolio_name: portfolio_main.portfolio_name,
          description: "Another Description"
        )
        refute duplicate_portfolio.valid?
        assert_includes duplicate_portfolio.errors[:portfolio_name], "has already been taken"
      end
    end
  end
end
