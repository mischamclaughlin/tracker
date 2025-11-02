COINGECKO_MAPPING = YAML.load_file(
                  Rails.root.join(
                    'config', 'coingecko_mapping.yml'
                  )
).freeze
