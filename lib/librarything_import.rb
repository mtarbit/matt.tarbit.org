#!/usr/bin/ruby

require 'csv'
require 'time'

delete_indices = [2,4,5,7,8,9,11,12,13].reverse

csv = CSV.read('librarything.csv')
csv.each_with_index do |row,i|

  # For everything but the header row...
  if i>0
    # Strip square-brackets from around the 10 digit ISBN
    row[6].sub!(/\[([0-9]{10})\]/,'\1')
    # Convert entry date string to unix timestamp
    row[10] = Time.parse(row[10]).to_i
  end

  # Delete the columns we aren't going to be using
  delete_indices.each {|i| row.delete_at(i) }
  
  puts row.join(", ")
end