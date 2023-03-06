require 'csv'

def parse_csv(file, headers: true)
  CSV.read(file, headers:, header_converters: :symbol)
end

# table name is in column "table name"
# column name is in column "column"
# index name is in column "index name"
# return a hash of table_name to hash of index names to arrays of column names
def parse_column_per_index(csv)
  csv.each_with_object({}) do |row, result|
    table_name = row[:table_name]
    index_name = row[:index_name]
    column_name = row[:column]
    result[table_name] ||= {}
    result[table_name][index_name] ||= []
    result[table_name][index_name] << column_name
  end
end


def display_indexes_decisions(table_name)
  csv_indexes = parse_csv('2023 Q1 OKRS and Scenario workshop - [REF] DB1 Columns used by indexes.csv')

  table_indexes = parse_column_per_index(csv_indexes)[table_name]
  all_table_indexes = table_indexes.keys

  # parse "2023 Q1 OKRS and Scenario workshop - Appointments Yak Shaving.csv" file
  # to get the indexes we want to keep or not
  csv_table_shaving = parse_csv("2023 Q1 OKRS and Scenario workshop - #{table_name.capitalize} Yak Shaving.csv", headers: false)

  # ignore 3 first rows
  # for each rows, first column is column name, 6th column is a rating (0 we want to keep, 10 we want to remove the column)
  appointments_shaving = csv_table_shaving.drop(3).each_with_object({}) do |row, result|
    column_name = row[0]
    rating = row[5]
    result[column_name] = rating
  end

  # for each table, for each index, for each column, check if we want to keep the column
  # if we want to keep the column, add it to the list of columns to keep
  # if we want to remove the column, remove it from the list of columns to keep
  # for each index, if no column is left, remove the index
  table_indexes.each do |index_name, columns|
    columns.keep_if do |column|
      appointments_shaving[column].to_i < 5
    end
    table_indexes.delete(index_name) if columns.empty?
  end

  # print the indexes we want to keep
  table_indexes.each do |index_name, columns|
    cols = columns.map{|col| "#{col}\t#{appointments_shaving[col].to_i}"}
    puts "#{index_name}\t1\t#{cols.join("\t")}"
  end

  (all_table_indexes - table_indexes.keys).each do |index_name|
    puts "#{index_name}\t0"
  end
end

display_indexes_decisions('patients')