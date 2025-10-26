require "rake/testtask"

namespace :test do
  desc "Run tests for lib classes"
  Rake::TestTask.new(:lib) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/lib/**/*_test.rb"]
    t.verbose = true
  end

  desc "Run tests for models"
  Rake::TestTask.new(:models) do |t|
    t.libs << "test"
    t.test_files = FileList["test/models/**/*_test.rb"]
    t.verbose = true
  end

  desc "Run tests for services"
  Rake::TestTask.new(:services) do |t|
    t.libs << "test"
    t.test_files = FileList["test/services/**/*_test.rb"]
    t.verbose = true
  end

  desc "Run integration tests"
  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.test_files = FileList["test/integration/**/*_test.rb"]
    t.verbose = true
  end

  desc "Run all tests"
  task all: [:lib, :models, :services, :integration]
end

desc "Run all tests (default)"
task test: "test:all"

