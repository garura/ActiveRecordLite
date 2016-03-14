require_relative 'associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL, send(through_options.foreign_key))
        SELECT
          #{source_options.model_class.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.model_class.table_name}
          ON #{through_options.table_name}.#{source_options.foreign_key} = #{source_options.model_class.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.table_name}.id = ?
      SQL
      source_options.model_class.new(results.first)
    end
  end
end
