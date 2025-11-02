module SafeOrdering
  extend ActiveSupport::Concern

  class_methods do
    def order_by_column(column, direction = :desc)
      safe_column = self::ALLOWED_COLUMNS.include?(column) ? column : self::ALLOWED_COLUMNS.first
      safe_direction = %w[asc desc].include?(direction.to_s.downcase) ? direction : :desc
      order(Arel.sql("#{safe_column} #{safe_direction}"))
    end
  end
end
