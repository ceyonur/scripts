#!/usr/bin/env ruby
# This script runs bundle update on gems specified in txt file.
# Requirements: Bundler
#[+ = major, * = minor, - = patch]
PATCH = '-'
MINOR = '*'
MAJOR = '+'

def main
  selected_update = MINOR
  print_name = case selected_update
                when PATCH
                  'patch'
                when MINOR
                  'minor'
                when MAJOR
                  'major'
                end

  txt_path = 'bundle_outdated_sample.txt'
  File.readlines(txt_path).drop(1).each do |line|
    if line[0] == selected_update
      split = line.split('(')
      gem = split.first.split(selected_update)[1].strip
      versions = split[1].split(')').first.split(',')
      from_version = versions[1].strip.split(' ')[1]
      to_version = versions[0].strip.split(' ')[1]

      puts `bundle update #{gem} --#{print_name} --ruby --quiet --jobs=8`
      puts `git add .`
      puts `git commit -m 'updated #{gem} #{from_version} ~> #{to_version}'`
    end
  end
end

main
