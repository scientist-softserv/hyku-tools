# tool for reviewing/comparing files. Save to bin/review_files_added_to_hyku.rb
# loops through each + line, open file, wait for our response, write to comment file, move on.
# This addresses the + line of the comp.txt

# first run Jeremy's knapsacker script and save to comp.txt
# touch file: reviewed_files_added_to_hyku.txt

# ruby bin/review_files_added_to_hyku.rb

notes = [ ]

File.readlines('/Users/kirk/Desktop/projects/hyku/reviewed_changed.txt').each do |line|
  notes << line
end

begin
  File.readlines('/Users/kirk/Desktop/projects/hyku/to_review.txt').each do |line|
    line.strip!
    next unless line.start_with?('Δ')
    next unless notes.detect { |note| note.start_with?("#{line}::") }.nil?
    puts line

    file_name = line.sub(/^Δ/, '').strip
    `code -d #{file_name} ../gems/hyrax/#{file_name}`
    puts "Review the file in VSCode. Then switch back to this terminal and enter your note for #{file_name}:"
    note = gets.chomp
    notes << "#{line}::#{note.strip}"

  end
ensure
  File.open('/Users/kirk/Desktop/projects/hyku/reviewed_changed.txt', 'w') do |f|
    notes.each do |note|
      f.puts note
    end
  end
end
