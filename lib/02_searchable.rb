require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |key, value| "#{key} = ?"}
    where_line = where_line.join(" AND ")
  results =  DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
         #{self.table_name}
      WHERE
        #{where_line}
    SQL
    results.map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end


# col_names = self.class.columns.drop(1)
# set_col_names = col_names.map { |col| "#{col} = ?" }
# set_col_names = set_col_names.join(", ")
# attr_values = self.attribute_values.drop(1)
#
# DBConnection.execute(<<-SQL, attr_values, self.id)
#   UPDATE
#
#   SET
#     #{set_col_names}
#   WHERE
#     id = ?
