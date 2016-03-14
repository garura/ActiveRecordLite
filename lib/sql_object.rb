require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map { |column| column.to_sym}
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end



  def self.finalize!
    columns.each do |column|

      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end

    end
  end



  def self.table_name=(table_name)
    @table_name = table_name
  end



  def self.table_name
    @table_name || self.name.tableize
  end



  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end



  def self.parse_all(results)
    results.map { |params| new(params) }
  end



  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(results).first
  end



  def initialize(params = {})
    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
      send("#{key.to_sym}=", value)
    end
  end



  def attributes
    @attributes ||= {}
  end



  def attribute_values
    self.class.columns.map { |col| send(col) }
  end



  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * (self.class.columns.length)).join(", ")

    results = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end



  def update
    set_line = self.class.columns.map { |column| "#{column} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end



  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
