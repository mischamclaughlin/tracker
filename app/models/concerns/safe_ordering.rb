module SafeOrdering
  extend ActiveSupport::Concern

  class_methods do
    def order_by_column(column, direction = :asc)
      safe_column = self::ALLOWED_COLUMNS.include?(column) ? column : self::ALLOWED_COLUMNS.first
      safe_direction = %w[asc desc].include?(direction.to_s.downcase) ? direction : :asc

      if self::ALPHA_COLS.include?(safe_column)
        safe_direction = safe_direction.to_s.downcase == 'asc' ? 'desc' : 'asc'
      end

      order(Arel.sql("#{safe_column} #{safe_direction}"))
    end
  end
end
