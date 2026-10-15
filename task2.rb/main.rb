
# Itransition Internship - Task 02
# Phase 05: SHA3-256 Hashing

require "openssl"
require "pathname"

ROOT = __dir__
DATA_FOLDER = File.join(ROOT, "task2")

puts "=== TASK 2: PHASE 05 ==="

# Step 1: Verify SHA3-256 support
begin
  digest = OpenSSL::Digest.new("SHA3-256")

  expected = "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532"
  actual = digest.hexdigest("abc")

  abort "ERROR: SHA3-256 self-test failed!" unless actual == expected

  puts "\n[1] SHA3-256 SETUP"
  puts "Algorithm: SHA3-256"
  puts "Self-test: PASS"

rescue OpenSSL::Digest::DigestError => e
  abort "ERROR: SHA3-256 is not supported: #{e.message}"
end

# Step 2: Find binary files
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

# Step 3: Read and hash every binary file
file_details = []
hashes = []
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

    hashes << hash
    total_bytes += data.bytesize
  end

rescue SystemCallError, IOError, OpenSSL::OpenSSLError => e
  abort "ERROR: File processing failed: #{e.message}"
end

puts "\n[3] BINARY PROCESSING"
puts "Successfully read: #{file_details.length} files"
puts "Total binary bytes: #{total_bytes}"

# Step 4: Verify hash format
valid_hashes = hashes.all? do |hash|
  hash.match?(/\A[0-9a-f]{64}\z/)
end

puts "\n[4] HASH VERIFICATION"
puts "Total hashes generated: #{hashes.length}"
puts "All hashes are 64 lowercase hex characters: #{valid_hashes ? 'PASS' : 'FAIL'}"

abort "ERROR: Invalid hash format!" unless valid_hashes
abort "ERROR: Hash count mismatch!" unless hashes.length == files.length

# Step 5: Display first 10 hashes
puts "\n[5] FIRST 10 SHA3-256 HASHES"

file_details.first(10).each_with_index do |file, index|
  puts "\n#{index + 1}. #{file[:name]}"
  puts "Size: #{file[:size]} bytes"
  puts "SHA3-256: #{file[:hash]}"
end

# Step 6: Final verification
puts "\n[6] FINAL RESULT"
puts "SHA3-256 algorithm: PASS"
puts "Binary reading: PASS"
puts "Hash generation: PASS"
puts "Hash format: PASS"
puts "Total files processed: #{file_details.length}"
puts "Total hashes generated: #{hashes.length}"
puts "Total bytes processed: #{total_bytes}"

puts "\nPHASE 05 COMPLETED SUCCESSFULLY"
