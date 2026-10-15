require "openssl"

ROOT = __dir__
DATA_FOLDER = File.join(ROOT, "task2")

puts "=== TASK 2: PHASE 08 ==="

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
abort "ERROR: task2 folder not found!" unless Dir.exist?(DATA_FOLDER)

files = Dir.glob(
  File.join(DATA_FOLDER, "**", "*"),
  File::FNM_DOTMATCH
).select { |path| File.file?(path) }.sort

abort "ERROR: No files found!" if files.empty?

puts "\n[2] FILE DISCOVERY"
puts "Total files discovered: #{files.length}"

# Step 3: Generate SHA3-256 hashes
file_details = []
total_bytes = 0

begin
  files.each do |path|
    data = File.binread(path)
    hash = OpenSSL::Digest.new("SHA3-256").hexdigest(data)

    file_details << {
      name: File.basename(path),
      size: data.bytesize,
      hash: hash
    }

    total_bytes += data.bytesize
  end

rescue SystemCallError, IOError, OpenSSL::OpenSSLError => e
  abort "ERROR: File processing failed: #{e.message}"
end

valid_hashes = file_details.all? do |file|
  file[:hash].match?(/\A[0-9a-f]{64}\z/)
end

abort "ERROR: Invalid SHA3-256 hash!" unless valid_hashes

puts "\n[3] HASH GENERATION"
puts "Files processed: #{file_details.length}"
puts "Hashes generated: #{file_details.length}"
puts "Total binary bytes: #{total_bytes}"
puts "Hash format: PASS"

# Step 4: Calculate custom sorting keys
def calculate_sorting_key(hash)
  hash.chars.map { |digit| digit.to_i(16) + 1 }.reduce(1, :*)
end

unless calculate_sorting_key("0a2f") == 528 &&
       calculate_sorting_key("1234") == 120
  abort "ERROR: Sorting formula self-test failed!"
end

file_details.each do |file|
  file[:sorting_key] = calculate_sorting_key(file[:hash])
end

sorted_files = file_details.sort_by { |file| file[:sorting_key] }
sorted_hashes = sorted_files.map { |file| file[:hash] }
sorted_keys = sorted_files.map { |file| file[:sorting_key] }

ascending = sorted_keys.each_cons(2).all? { |a, b| a <= b }

original_hashes = file_details.map { |file| file[:hash] }
preserved = sorted_hashes.sort == original_hashes.sort

abort "ERROR: Sorting verification failed!" unless ascending && preserved

puts "\n[4] CUSTOM SORTING"
puts "Sorting formula: PASS"
puts "Ascending order: PASS"
puts "Original hashes preserved: PASS"
puts "Total sorted hashes: #{sorted_hashes.length}"

# Step 5: Join sorted original hashes
joined_hashes = sorted_hashes.join
expected_hash_length = sorted_hashes.length * 64

unless joined_hashes.length == expected_hash_length &&
       joined_hashes.match?(/\A[0-9a-f]+\z/)
  abort "ERROR: Joined hash string is invalid!"
end

puts "\n[5] HASH CONCATENATION"
puts "Separator: NONE"
puts "Joined hashes: #{sorted_hashes.length}"
puts "Expected length: #{expected_hash_length}"
puts "Actual length: #{joined_hashes.length}"
puts "Concatenation: PASS"

# Step 6: Read registered email
puts "\n[6] EMAIL VALIDATION"
print "Enter registered email: "

email_input = STDIN.gets
abort "ERROR: Email input missing!" if email_input.nil?

email = email_input.strip.downcase

if email.empty? || email.match?(/\s/) ||
   !email.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
  abort "ERROR: Invalid email format!"
end

puts "Email length: #{email.length}"
puts "Lowercase conversion: PASS"
puts "Email validation: PASS"

# Step 7: Concatenate hashes and email
final_string = joined_hashes + email
expected_final_length = expected_hash_length + email.length

valid_final_string =
  final_string.length == expected_final_length &&
  final_string.start_with?(joined_hashes) &&
  final_string.end_with?(email)

abort "ERROR: Final string verification failed!" unless valid_final_string

puts "\n[7] FINAL CONCATENATION"
puts "Hashes length: #{joined_hashes.length}"
puts "Email length: #{email.length}"
puts "Expected total length: #{expected_final_length}"
puts "Actual total length: #{final_string.length}"
puts "Concatenation validation: PASS"

# Step 8: Generate FINAL SHA3-256 hash
final_hash = OpenSSL::Digest.new("SHA3-256").hexdigest(final_string)

# Step 9: Validate final hash
valid_final_hash = final_hash.match?(/\A[0-9a-f]{64}\z/)

abort "ERROR: Final hash validation failed!" unless valid_final_hash

puts "\n[8] FINAL SHA3-256 VERIFICATION"
puts "Algorithm: SHA3-256"
puts "Input string length: #{final_string.length}"
puts "Final hash length: #{final_hash.length}"
puts "Lowercase hexadecimal: PASS"
puts "Final hash validation: PASS"

# Step 10: Final report
puts "\n[9] FINAL RESULT"
puts "SHA3-256 self-test: PASS"
puts "Binary processing: PASS"
puts "Hash generation: PASS"
puts "Custom sorting: PASS"
puts "Hash concatenation: PASS"
puts "Email normalization: PASS"
puts "Final SHA3-256: PASS"
puts "Total files processed: #{file_details.length}"
puts "Total hashes joined: #{sorted_hashes.length}"
puts "Total binary bytes: #{total_bytes}"

puts "\nFINAL SHA3-256 HASH:"
puts final_hash
puts(" ")
