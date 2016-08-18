module RubyUtils
  module_function

  def find_executable(name)
    if File.exist?("bin/#{name}")
      ["bin/#{name}"]
    elsif File.exist?('Gemfile.lock') && File.read('Gemfile.lock') =~ /^    #{name} /
      %W(bundle exec #{name})
    else
      [name]
    end
  end
end

