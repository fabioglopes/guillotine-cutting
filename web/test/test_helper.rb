ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"

# Load library files from parent directory
lib_path = File.expand_path('../../lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Store references to Rails models before loading lib
RailsPiece = ::Piece
RailsSheet = ::Sheet

# Require lib files (these will override Piece and Sheet constants)
require File.join(lib_path, 'piece')
require File.join(lib_path, 'sheet')
require File.join(lib_path, 'cutting_optimizer')
require File.join(lib_path, 'guillotine_bin_packer')
require File.join(lib_path, 'input_loader')
require File.join(lib_path, 'step_parser')
require File.join(lib_path, 'linear_optimizer')
require File.join(lib_path, 'linear_report_generator')
require File.join(lib_path, 'report_generator')

# Create aliases for lib classes
LibPiece = ::Piece
LibSheet = ::Sheet

# Restore Rails models
Object.send(:remove_const, :Piece) if defined?(::Piece)
Object.send(:remove_const, :Sheet) if defined?(::Sheet)
::Piece = RailsPiece
::Sheet = RailsSheet

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

