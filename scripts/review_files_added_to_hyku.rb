notes = [ ] 

File.readlines('/Users/shana/Work/hyku/reviewed_files_added_to_hyku.txt').each do |line|
  notes << line
end

# Pre-calculate the number of lines to be processed
lines_to_process = File.readlines('/Users/shana/Work/hyku/to_review.txt').count do |line|
  line.strip!
  line.start_with?('+') && notes.detect { |note| note.start_with?("#{line}::") }.nil?
end

begin
  File.readlines('/Users/shana/Work/hyku/to_review.txt').each do |line|
    line.strip!
    next unless line.start_with?('+')
    next unless notes.detect { |note| note.start_with?("#{line}::") }.nil?
    puts line

    file_name = line.sub(/^\+/, '').strip
    `code -r #{file_name}`
    puts "Review the file in VSCode. Then switch back to this terminal and enter your note for #{file_name}:"
    note = gets.chomp
    notes << "#{line}::#{note.strip}"

    # Decrement the lines to process count and print it
    lines_to_process -= 1
    puts "#{lines_to_process} lines left to process."
  end
ensure
  File.open('/Users/shana/Work/hyku/reviewed_files_added_to_hyku.txt', 'w') do |f|
    notes.each do |note|
      f.puts note
    end
  end
end

# tool to loop through each + line, open file, wait for our response, write to comment file, move on.
