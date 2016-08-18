require 'minitest/autorun'
require "#{__dir__}/../lib/ruby_utils"

class TestRubyUtilsFindExecutable < Minitest::Test
  def in_project_with_binstub_for(executable)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir)
      FileUtils.mkdir('bin')
      FileUtils.touch("bin/#{executable}")
      yield
    end
  end

  def in_project_with_gemfile_entry_for(executable)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir)
      File.write 'Gemfile.lock', <<-STR.gsub(/^        /, '')
        GEM
          remote: https://rubygems.org/
          specs:
            #{executable} (1.2.3)
      STR
      yield
    end
  end

  def test_find_binstub
    in_project_with_binstub_for('foobar') do
      assert_equal ['bin/foobar'], RubyUtils.find_executable('foobar')
      FileUtils.rm('bin/foobar')
      refute_equal ['bin/foobar'], RubyUtils.find_executable('foobar')
    end
  end

  def test_find_in_gemfile
    in_project_with_gemfile_entry_for('foobar') do
      assert_equal %w(bundle exec foobar), RubyUtils.find_executable('foobar')
      FileUtils.rm('Gemfile.lock')
      refute_equal %w(bundle exec foobar), RubyUtils.find_executable('foobar')
    end
  end
end
