# ================================= USERS ================================= #
u1 = { first_name: 'Mischa', last_name: 'McLaughlin', username: 'mischamclaughlin', email: 'mischa@example.com' }
u2 = { first_name: 'Alex', last_name: 'Johnson', username: 'alexjohnson', email: 'alex@example.com' }
u3 = { first_name: 'Samantha', last_name: 'Lee', username: 'samanthalee', email: 'samantha@example.com' }
u4 = { first_name: 'David', last_name: 'Kim', username: 'davidkim', email: 'david@example.com' }
u5 = { first_name: 'Emily', last_name: 'Davis', username: 'emilydavis', email: 'emily@example.com' }
users = [u1, u2, u3, u4, u5]
pwd = ENV['SEED_PWD'].presence || 'dev123456'

users.each do |user_attrs|
  user = User.find_or_initialize_by(username: user_attrs[:username])
  user.assign_attributes(user_attrs)
  if user.new_record? || user.encrypted_password.blank?
    user.password = pwd
    user.password_confirmation = pwd
  end
  user.save!
end
puts "Seeded #{User.count} users."


# ================================= COINS ================================= #
c1 = { coin_name: 'Bitcoin', symbol: 'BTC', coingecko_id: 'bitcoin' }
c2 = { coin_name: 'Ethereum', symbol: 'ETH', coingecko_id: 'ethereum' }
c3 = { coin_name: 'Litecoin', symbol: 'LTC', coingecko_id: 'litecoin' }
c4 = { coin_name: 'Ripple', symbol: 'XRP', coingecko_id: 'ripple' }
c5 = { coin_name: 'Cardano', symbol: 'ADA', coingecko_id: 'cardano' }
coins = [c1, c2, c3, c4, c5]

coins.each do |coin_attrs|
  Coin.find_or_create_by!(symbol: coin_attrs[:symbol]) do |coin|
    coin.coin_name = coin_attrs[:coin_name]
    coin.symbol = coin_attrs[:symbol]
    coin.coingecko_id = coin_attrs[:coingecko_id]
  end
end
puts "Seeded #{Coin.count} coins."


# ============================== PORTFOLIOS =============================== #
p1 = { portfolio_name: 'Long Term Holdings', description: 'A portfolio for long term investments.', user_id: User.first.id }
p2 = { portfolio_name: 'Short Term Trades', description: 'A portfolio for short term trading activities.', user_id: User.first.id }
p3 = { portfolio_name: 'Altcoin Investments', description: 'A portfolio focused on altcoin investments.', user_id: User.second.id }
p4 = { portfolio_name: 'DeFi Portfolio', description: 'A portfolio for decentralized finance assets.', user_id: User.third.id }
p5 = { portfolio_name: 'NFT Collection', description: 'A portfolio for tracking NFT investments.', user_id: User.fourth.id }
portfolios = [p1, p2, p3, p4, p5]

portfolios.each do |portfolio_attrs|
  Portfolio.find_or_create_by!(portfolio_name: portfolio_attrs[:portfolio_name]) do |portfolio|
    portfolio.portfolio_name = portfolio_attrs[:portfolio_name]
    portfolio.description = portfolio_attrs[:description]
    portfolio.user_id = portfolio_attrs[:user_id]
  end
end
puts "Seeded #{Portfolio.count} portfolios."
puts "Seeding complete."
