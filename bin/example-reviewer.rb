# This file demonstrates an example of how we might methodically review files that are of interest.
# The concept of LEFT and RIGHT maps to the the ./bin/left_v_right script.
require 'fileutils'

LEFT = "#{ENV['HOME']}/git/hyku"
RIGHT = "#{ENV['HOME']}/git/hyrax"
original_notes = []
notes = []

FileUtils.touch("#{ENV['HOME']}/reviewed.txt") unless File.exist?("#{ENV['HOME']}/reviewed.txt")

File.readlines("#{ENV['HOME']}/reviewed.txt").each { |line| original_notes << line }

begin
  # What would the experience be if we randomized these lines?  As is, we will prompt in order.
  # Also, imagine instead of reading a file we take the results of STDIN.  This way we would always
  # be running the notes against the current state.
  File.readlines("#{ENV['HOME']}/to-review.txt").each do |line|
    line = line.strip
    prefix = line[0]
    filename = line[2..-1]

    next if original_notes.detect { |n| n.start_with?(line) }

    case prefix
    when "<"
      print "Reviewing #{filename.inspect}: "
      # Since the file is in LEFT but not RIGHT, we want to review the LEFT file and take notes
      `code #{File.join(LEFT, filename)}`

      # This is a naive input mechanism; the typing experience is sub-par without terminal readlines
      # support.
      note = gets.chomp
    when ">"
      note = "Skipped"
    when "Δ"
      print "Reviewing #{filename.inspect}: "
      # This will show a diff between the file in the LEFT and RIGHT
      `code -d #{File.join(LEFT, filename)} #{File.join(RIGHT, filename)}`
      note = gets.chomp
    when "="
      FileUtils.rm(File.join(LEFT, filename))
      note = "Removed"
    end

    notes << "#{line}\t#{note.strip}" unless note.to_s.strip.size.zero?
  end
ensure
  File.open("#{ENV['HOME']}/reviewed.txt", 'w') do |file|
    (original_notes + notes).each do |note|
      file.puts note
    end
  end
end
