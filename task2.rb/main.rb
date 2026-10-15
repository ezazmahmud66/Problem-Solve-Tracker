
#File Verification

folder = File.join(__dir__, "task2")

unless Dir.exist?(folder)
  abort "ERROR: task2 folder not found!"
end

files = Dir.glob(File.join(folder, "**", "*"), File::FNM_DOTMATCH)
           .select { |path| File.file?(path) }
           .sort

puts "Folder: #{folder}"
puts "Total files: #{files.length}"

puts "\nFirst 10 files:"

files.first(10).each_with_index do |file, index|
  puts "#{index + 1}. #{File.basename(file)}"
end

if files.empty?
  puts "\nERROR: No files found!"
else
  puts "\nSUCCESS: Files discovered!"
end


unless files.empty?
  first_file = files.first
  data = File.binread(first_file)

  puts "\nBinary file verification:"
  puts "File: #{File.basename(first_file)}"
  puts "Size: #{data.bytesize} bytes"
  puts "First bytes: #{data.bytes.first(16).map { |b| "%02x" % b }.join(" ")}"
end

