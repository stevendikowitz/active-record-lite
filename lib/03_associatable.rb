require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".downcase.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".camelcase
    # debugger
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name}_id".downcase.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
     options = BelongsToOptions.new(name, options)

     define_method(name) do
       options.model_class.where(options.primary_key => self.send(options.foreign_key)).first
     end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(name) do
      options.model_class.where(options.foreign_key => self.send(options.primary_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
