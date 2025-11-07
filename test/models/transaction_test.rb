require "test_helper"

describe Transaction do
  let(:coin) { coins(:bitcoin) }
  let(:portfolio) { portfolios(:main) }
  let(:price) { prices(:bitcoin_current_price) }
  let(:transaction_buy_bitcoin) { transactions(:buy_bitcoin) }
  let(:transaction_sell_ethereum) { transactions(:sell_ethereum) }
  let(:holding_bitcoin_main) { holdings(:main_bitcoin) }

  
  context "when calling public methods" do
    describe "#to_s" do
      it "returns a string representation of the transaction" do
        expected_string = "
        Transaction ID: #{transaction_buy_bitcoin.id},
        Coin ID: #{transaction_buy_bitcoin.coin_id},
        Portfolio ID: #{transaction_buy_bitcoin.portfolio_id},
        Action: #{transaction_buy_bitcoin.action},
        Time: #{transaction_buy_bitcoin.time.strftime("%d/%m/%Y %H:%M:%S")},
        Memo: #{transaction_buy_bitcoin.memo},
        Fiat Amount: $#{transaction_buy_bitcoin.fiat_amount.to_s("F")},
        Coin Amount: #{transaction_buy_bitcoin.coin_amount.to_s("F")},
        ".squish

        assert_equal expected_string, transaction_buy_bitcoin.to_s
      end
    end
  end


  describe "associations" do
    context "#coin_information" do
      it "returns the associated coin" do
        assert_equal coin, transaction_buy_bitcoin.coin_information
      end
    end
  
    context "#portfolio_information" do
      it "returns the associated portfolio" do
        assert_equal portfolio, transaction_buy_bitcoin.portfolio_information
      end
    end
  end


  describe "validations" do
    let(:valid_attributes) do
      {
        coin_id: coin.id,
        portfolio_id: portfolio.id,
        action: "buy",
        time: Time.current,
        fiat_amount: 1000.0,
        coin_amount: 0
      }
    end

    context "when a valid transaction" do
      it "returns valid when all attributes are present" do
        assert Transaction.new(valid_attributes).valid?
      end
    end

    context "when an invalid transaction" do
      it "returns invalid when missing coin_id" do
        transaction = Transaction.new(valid_attributes.except(:coin_id))
        refute transaction.valid?
        assert_includes transaction.errors[:coin_id], "can't be blank"
      end
      it "returns invalid when missing portfolio_id" do
        transaction = Transaction.new(valid_attributes.except(:portfolio_id))
        refute transaction.valid?
        assert_includes transaction.errors[:portfolio_id], "can't be blank"
      end
      it "returns invalid when action is not in allowed list" do
        transaction = Transaction.new(valid_attributes.merge(action: "invalid_action"))
        refute transaction.valid?
        assert_includes transaction.errors[:action], "is not included in the list"
      end
      it "returns invalid when time is missing" do
        transaction = Transaction.new(valid_attributes.except(:time))
        refute transaction.valid?
        assert_includes transaction.errors[:time], "can't be blank"
      end
      it "returns invalid when fiat_amount is negative" do
        transaction = Transaction.new(valid_attributes.merge(fiat_amount: -100))
        refute transaction.valid?
        assert_includes transaction.errors[:fiat_amount], "must be greater than or equal to 0"
      end
      it "returns invalid when coin_amount is negative" do
        transaction = Transaction.new(valid_attributes.merge(coin_amount: -0.5))
        refute transaction.valid?
        assert_includes transaction.errors[:coin_amount], "must be greater than or equal to 0"
      end
    end

    context "before_validation callbacks" do
      describe "#normalise_attributes" do
        it "normalises action and memo attributes" do
          transaction = Transaction.new(valid_attributes.merge(action: "  BUY  ", memo: "  Test Memo  "))
          transaction.valid?
          assert_equal "buy", transaction.action
          assert_equal "Test Memo", transaction.memo
        end
      end
      describe "#ensure_coin_exists" do
        it "adds error if coin_identifier is provided but coin does not exist" do
          transaction = Transaction.new(valid_attributes.except(:coin_id).merge(coin_identifier: "NonExistentCoin"))
          transaction.valid?
          assert_includes transaction.errors[:coin_identifier], "Coin with identifier 'NonExistentCoin' does not exist."
        end
        it "sets coin_id if coin_identifier matches an existing coin" do
          transaction = Transaction.new(valid_attributes.except(:coin_id).merge(coin_identifier: coin.symbol))
          transaction.valid?
          assert_equal coin.id, transaction.coin_id
        end
      end
      describe "#ensure_portfolio_exists" do
        it "creates a new portfolio if portfolio_identifier does not match any existing portfolio" do
          unique_portfolio_name = "UniquePortfolio#{SecureRandom.hex(4)}"
          transaction = Transaction.new(valid_attributes.except(:portfolio_id).merge(portfolio_identifier: unique_portfolio_name))
          transaction.valid?
          created_portfolio = Portfolio.find_by(portfolio_name: unique_portfolio_name)
          assert created_portfolio, "Expected portfolio to be created"
          assert_equal created_portfolio.id, transaction.portfolio_id
        end
        it "sets portfolio_id if portfolio_identifier matches an existing portfolio" do
          transaction = Transaction.new(valid_attributes.except(:portfolio_id).merge(portfolio_identifier: portfolio.portfolio_name))
          transaction.valid?
          assert_equal portfolio.id, transaction.portfolio_id
        end
      end
      describe "#ensure_amount_provided" do
        it "adds error if both fiat_amount and coin_amount are zero" do
          transaction = Transaction.new(valid_attributes.merge(fiat_amount: 0, coin_amount: 0))
          transaction.valid?
          assert_includes transaction.errors[:base], "Either fiat amount or coin amount must be provided and greater than zero."
        end
        it "is valid if either fiat_amount or coin_amount is greater than zero" do
          transaction1 = Transaction.new(valid_attributes.merge(fiat_amount: 100, coin_amount: 0))
          assert transaction1.valid?

          transaction2 = Transaction.new(valid_attributes.merge(fiat_amount: 0, coin_amount: 0.5))
          assert transaction2.valid?
        end

        context "when fiat_amount is provided but coin_amount is zero" do
          it "calculates coin_amount based on fiat_amount and current coin price" do
            current_price = price.price
            fiat_amount = 1000.0
            expected_coin_amount = fiat_amount / current_price

            transaction = Transaction.new(valid_attributes.merge(fiat_amount: fiat_amount, coin_amount: 0))
            transaction.valid?
            assert_in_delta expected_coin_amount, transaction.coin_amount, 0.0001
          end
        end

        context "when coin_amount is provided but fiat_amount is zero" do
          it "calculates fiat_amount based on coin_amount and current coin price" do
            current_price = price.price
            coin_amount = 5.0
            expected_fiat_amount = coin_amount * current_price

            transaction = Transaction.new(valid_attributes.merge(fiat_amount: 0, coin_amount: coin_amount))
            transaction.valid?
            assert_in_delta expected_fiat_amount, transaction.fiat_amount, 0.0001
          end
        end
      end
    end

    context "after_create callbacks" do
      describe "#update_holding_balance" do
        context "when no holding exists" do
          it "creates a new holding if none exists for the coin and portfolio" do
            unique_coin = Coin.create!(coin_name: "UniqueCoin", symbol: "UNQ", coingecko_id: "uniquecoin123")
            unique_portfolio = Portfolio.create!(portfolio_name: "UniquePortfolio")
            Transaction.create!(valid_attributes.merge(coin_id: unique_coin.id, portfolio_id: unique_portfolio.id, fiat_amount: 200, coin_amount: 5))
            holding = Holding.find_by(coin_id: unique_coin.id, portfolio_id: unique_portfolio.id)
            assert holding, "Expected holding to be created"
            assert_equal 5, holding.coin_balance
          end
        end

        context "when a holding already exists" do
          it "does not create a new holding if one already exists for the coin and portfolio" do
            initial_holding_count = Holding.count
            Transaction.create!(valid_attributes.merge(coin_id: coin.id, portfolio_id: portfolio.id))
            assert_equal initial_holding_count, Holding.count, "Expected no new holding to be created"
          end
        end

        context "when action is 'buy'" do
          it "increases the coin balance in the associated holding" do
            initial_balance = portfolio.total_coin_balance_for(coin)
            Transaction.create!(valid_attributes.merge(fiat_amount: 0, coin_amount: 10))
            updated_balance = portfolio.total_coin_balance_for(coin)
            assert_equal initial_balance + 10, updated_balance
          end
        end

        context "when action is 'sell'" do
          it "decreases the coin balance in the associated holding" do
            Transaction.create!(valid_attributes.merge(fiat_amount: 0, coin_amount: 20))
            initial_balance = portfolio.total_coin_balance_for(coin)
            Transaction.create!(valid_attributes.merge(action: "sell", fiat_amount: 0, coin_amount: 5))
            updated_balance = portfolio.total_coin_balance_for(coin)
            assert_equal initial_balance - 5, updated_balance
          end
        end
      end
    end

    context "after_update callbacks" do
      describe "#reverse_old_and_apply_new_transaction" do
        context "reverses the effects of the old transaction and applies the new transaction changes" do
          it "correctly updates holding balances when action is changed from 'buy' to 'sell'" do
            transaction = Transaction.create!(valid_attributes.merge(fiat_amount: 0, coin_amount: 15))
            initial_balance = portfolio.total_coin_balance_for(coin)

            transaction.update!(action: "sell", fiat_amount: 0, coin_amount: 5)
            updated_balance = portfolio.total_coin_balance_for(coin)

            expected_balance = initial_balance - 15 - 5
            assert_equal expected_balance, updated_balance
            end
          it "correctly updates holding balances when action is changed from 'sell' to 'buy'" do
            transaction = Transaction.create!(valid_attributes.merge(action: "sell", fiat_amount: 0, coin_amount: 15))
            initial_balance = portfolio.total_coin_balance_for(coin)

            transaction.update!(action: "buy", fiat_amount: 0, coin_amount: 5)
            updated_balance = portfolio.total_coin_balance_for(coin)

            expected_balance = initial_balance + 15 + 5
            assert_equal expected_balance, updated_balance
          end
          it "correctly updates holding balances when action stays 'buy' but value changes" do
            transaction = Transaction.create!(valid_attributes.merge(action: "buy", fiat_amount: 0, coin_amount: 15))
            initial_balance = portfolio.total_coin_balance_for(coin)

            transaction.update!(action: "buy", fiat_amount: 0, coin_amount: 5)
            updated_balance = portfolio.total_coin_balance_for(coin)

            expected_balance = initial_balance - 15 + 5
            assert_equal expected_balance, updated_balance
          end
          it "correctly updates holding balances when action stays 'sell' but value changes" do
            transaction = Transaction.create!(valid_attributes.merge(action: "sell", fiat_amount: 0, coin_amount: 15))
            initial_balance = portfolio.total_coin_balance_for(coin)

            transaction.update!(action: "sell", fiat_amount: 0, coin_amount: 5)
            updated_balance = portfolio.total_coin_balance_for(coin)

            expected_balance = initial_balance + 15 - 5
            assert_equal expected_balance, updated_balance
          end
        end
      end
    end

    context "before_destroy callbacks" do
      describe "#reverse_transaction_from_holding" do
        it "reverses the effects of the transaction on the associated holding before destruction" do
          transaction = Transaction.create!(valid_attributes.merge(fiat_amount: 0, coin_amount: 10))
          initial_balance = portfolio.total_coin_balance_for(coin)

          transaction.destroy
          updated_balance = portfolio.total_coin_balance_for(coin)

          expected_balance = initial_balance - 10
          assert_equal expected_balance, updated_balance
        end
      end
    end
  end
end
