require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    query = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = query.first.map(&:to_sym)
  end

  def self.finalize!

    self.columns.each do |column|

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end

      define_method(column) do
        self.attributes[column]
      end

    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    query = DBConnection.execute(<<-SQL)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name};
    SQL

    self.parse_all(query)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end

  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
    LIMIT
      1
    SQL

    self.parse_all(results).first

  end

  def initialize(params = {})
    params.each do |attr_name|
      attr_value = attr_name.last
      attr_name = attr_name.first.to_sym

      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name)
      self.send(attr_name)
      self.send("#{attr_name}=", attr_value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    col_names = self.class.columns.drop(1).join(", ")
    question_marks = Array.new(self.attribute_values.length) { "?" }
    question_marks = question_marks.join(", ")

    DBConnection.execute(<<-SQL, self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.drop(1)
    set_col_names = col_names.map { |col| "#{col} = ?" }
    set_col_names = set_col_names.join(", ")
    attr_values = self.attribute_values.drop(1)

    DBConnection.execute(<<-SQL, attr_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_col_names}
      WHERE
        id = ?
    SQL

  end

  def save
    id.nil? ? insert : update
  end
end
