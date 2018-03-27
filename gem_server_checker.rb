#!/usr/bin/env ruby
# This script looks Gemfile.lock and given gem path to check gems are available.
# Requirements: Bundler
def main
  gems_path = 'path/to/gemserver/gems' # The actual directory where gems reside under gemserver
  output = `bundle show` # Need to install bundler
  unless($?.success?)
    str = output.delete("\n") + " under #{Dir.pwd}"
    puts make_color(str,:red)
    return
  end

  return 'Gem path not found' unless File.exist?(gems_path)

  puts 'Updating gem server path'
  `( cd #{gems_path}/ ; git checkout master ; git pull )`

  output_arr = output.delete(' ').delete('*').split("\n")
  output_arr.delete_at(0)
  results = {found: [], not_found: []}
  output_arr.each do |gem|
    gem_version = gem[/\((.*?)\)/,1]
    gem_name = gem.gsub(/\((.*?)\)/,'')
    gem_file_wildcard = "#{gems_path}/#{gem_name}-#{gem_version}{-*.gem,.gem}"
    unless Dir.glob(gem_file_wildcard).empty?
      results[:found] << gem_name + ' ' + gem_version
    else
      results[:not_found] << gem_name + ' ' + gem_version
    end
  end
  results[:found].each { |el| puts make_color("Found: #{el}",:green) }
  results[:not_found].each { |el| puts make_color("Not Found: #{el}",:red) }

  return if results[:not_found].empty?
  puts 'Do you want to add gems to gem server? (Y/N)'
  confirm = gets.chomp

  return unless confirm.casecmp('Y') == 0
  substr = "gems"
  dir = gems_path
  dir.slice!(gems_path.rindex(substr), substr.size)
  Dir.chdir(dir){
    puts "Run this command:"
    puts "cd #{dir} && wait; " + results[:not_found].map{ |gem| "./add_gem #{gem}" }.join(' & wait; ')
  }
end

def make_color(str, color)
  colors = {:red => 31, :green => 32, :blue => 34}
  "\e[#{colors[color]}m #{str}\e[0m"
end

main
