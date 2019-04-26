require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
   col = DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{self.table_name}
SQL
  col2 = col.first.map{|column_name| column_name.to_sym}
    @columns = col2
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
          self.attributes[column]
      end
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  # Now we can finally write ::finalize!. It should iterate 
  # through all the ::columns, using define_method (twice) to 
  # create a getter and setter method for each column, just like 
  # my_attr_accessor. But this time, instead of dynamically creating
  #  an instance variable, store everything in the #attributes hash.


  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
      @table_name || self.name.tableize
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
  SELECT
      *
  FROM
    #{self.table_name}
SQL
    parse_all(all)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    found = DBConnection.execute(<<-SQL, id)
  SELECT
      *
  FROM
    #{self.table_name}
    WHERE
     id = ?
SQL
    parse_all(found).first
  end

  def initialize(params = {})
    params.each do |atr_name, value|
      atr_name = atr_name.to_sym
      if self.class.columns.include?(atr_name)
         self.send("#{atr_name}=", value)
      else
        raise "unknown attribute '#{atr_name}'"
      end
    end
 
  end


  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values
  end

  # I wrote a SQLObject#attribute_values method that returns 
  # an array of the values for each attribute. I did this by 
  # calling Array#map on SQLObject::columns, calling send on the 
  # instance to get the value.

  def insert
  columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    question_marks = (["?"] * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns
      .map { |attr| "#{attr} = ?" }.join(", ")
  
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
    # ...
  end
end
