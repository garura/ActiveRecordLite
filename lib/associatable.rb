require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    name = name.to_s
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.camelcase
    @foreign_key = options[:foreign_key] || "#{name.underscore}_id".to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name = name.to_s
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @class_name = options[:class_name] || name.camelcase.singularize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = send(options.foreign_key)
      belong_class = options.model_class
      primary_key = options.primary_key
      belong_class.where(primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      (options.model_class).where(options.foreign_key => send(options.primary_key))
    end

  end

  def assoc_options
    @my_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
