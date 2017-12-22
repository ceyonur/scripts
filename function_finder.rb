# This script finds functions with given pattern in given file.
# Then it searches found functions in given directory then prints them out.
# The purpose of this script was to find references of functions in specific javascript under project.
# requires ack package: https://beyondgrep.com/


pattern = Regexp.new('^\s*function(\s+\w+\().*\)\s*')
functions_from = '/path/to/file' #file to extract regexp from
search_in = '/path/to/dir' #dir to search functions in
exclude_text= 'exclude_this' #to exclude specific path/filename

File.foreach(functions_from) do |line|
  matched = line.match(pattern)
  if matched
    search_term = matched.captures.first.strip
    search_term = search_term.insert(-2,'\\')
    output = `ack '#{search_term}' #{search_in}`
    reduced_output = exclude_text.empty? ? output : output.split("\n").reject do |element|
      element.include?(exclude_text)
    end
    unless(reduced_output.empty?)
      puts matched
      puts reduced_output
      puts "------------------"
    end
  end
end
