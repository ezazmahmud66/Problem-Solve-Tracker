
# Itransition Internship - Task 02
# Phase 06: Custom Hash Sorting

require "openssl"
require "pathname"

ROOT = __dir__
DATA_FOLDER = File.join(ROOT, "task2")

puts "=== TASK 2: PHASE 06 ==="

# Step 1: Verify SHA3-256 algorithm
begin
  expected = "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532"
  actual = OpenSSL::Digest.new("SHA3-256").hexdigest("abc")

  abort "ERROR: SHA3-256 self-test failed!" unless actual == expected

  puts "\n[1] SHA3-256 SETUP"
  puts "Algorithm: SHA3-256"
  puts "Self-test: PASS"

rescue OpenSSL::OpenSSLError => e
  abort "ERROR: SHA3-256 not supported: #{e.message}"
end

# Step 2: Discover binary files
unless Dir.exist?(DATA_FOLDER)
  abort "ERROR: task2 folder not found!"
end

files = Dir.glob(
  File.join(DATA_FOLDER, "**", "*"),
  File::FNM_DOTMATCH
).select { |path| File.file?(path) }.sort

abort "ERROR: No files found!" if files.empty?

puts "\n[2] FILE DISCOVERY"
puts "Total files discovered: #{files.length}"

# Step 3: Read files and calculate SHA3-256
file_details = []
total_bytes = 0

begin
  files.each do |path|
    data = File.binread(path)

    relative_path = Pathname.new(path)
      .relative_path_from(Pathname.new(DATA_FOLDER))
      .to_s
      .tr("\\", "/")

    hash = OpenSSL::Digest.new("SHA3-256").hexdigest(data)

    file_details << {
      name: relative_path,
      size: data.bytesize,
      hash: hash
    }

    total_bytes += data.bytesize
  end

rescue SystemCallError, IOError, OpenSSL::OpenSSLError => e
  abort "ERROR: File processing failed: #{e.message}"
end

puts "\n[3] HASH GENERATION"
puts "Files processed: #{file_details.length}"
puts "Total binary bytes: #{total_bytes}"
puts "Hashes generated: #{file_details.length}"

# Step 4: Verify hash format
valid_hashes = file_details.all? do |file|
  file[:hash].match?(/\A[0-9a-f]{64}\z/)
end

abort "ERROR: Invalid hash format!" unless valid_hashes

puts "Hash format: PASS"

# Step 5: Calculate custom sorting key
def calculate_sorting_key(hash)
  hash.chars.map { |digit| digit.to_i(16) + 1 }.reduce(1, :*)
end

# Verify sorting formula with known examples
unless calculate_sorting_key("0a2f") == 528 &&
       calculate_sorting_key("1234") == 120
  abort "ERROR: Sorting formula self-test failed!"
end

file_details.each do |file|
  file[:sorting_key] = calculate_sorting_key(file[:hash])
end

puts "\n[4] CUSTOM SORTING"
puts "Sorting formula self-test: PASS"
puts "Sorting keys generated: #{file_details.length}"

# Step 6: Sort by numerical product
sorted_files = file_details.sort_by do |file|
  file[:sorting_key]
end

sorted_hashes = sorted_files.map { |file| file[:hash] }

puts "Sorting direction: ASCENDING"
puts "Sorted hashes: #{sorted_hashes.length}"

# Step 7: Verify ascending order
sorted_keys = sorted_files.map { |file| file[:sorting_key] }

ascending = sorted_keys.each_cons(2).all? do |a, b|
  a <= b
end

same_hashes = sorted_hashes.sort == file_details.map { |file| file[:hash] }.sort

abort "ERROR: Sorting order is incorrect!" unless ascending
abort "ERROR: Hashes lost during sorting!" unless same_hashes

puts "\n[5] SORTING VERIFICATION"
puts "Ascending order: PASS"
puts "All original hashes preserved: PASS"

# Step 8: Show first 10 sorted hashes
puts "\n[6] FIRST 10 SORTED HASHES"

sorted_files.first(10).each_with_index do |file, index|
  puts "\n#{index + 1}. #{file[:name]}"
  puts "SHA3-256: #{file[:hash]}"
  puts "Sorting key: #{file[:sorting_key]}"
end

# Step 9: Final result
puts "\n[7] FINAL RESULT"
puts "SHA3-256 algorithm: PASS"
puts "Binary reading: PASS"
puts "Hash format: PASS"
puts "Custom sorting: PASS"
puts "Ascending order: PASS"
puts "Original hashes preserved: PASS"
puts "Total files processed: #{file_details.length}"
puts "Total hashes sorted: #{sorted_hashes.length}"
puts "Total binary bytes: #{total_bytes}"

puts "\nPHASE 06 COMPLETED SUCCESSFULLY"
