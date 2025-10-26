# Load optimizer library classes
lib_path = File.expand_path('../../../lib', __dir__)

# Load each file individually and store in variables to avoid conflicts
lib_piece_code = File.read(File.join(lib_path, 'piece.rb'))
lib_sheet_code = File.read(File.join(lib_path, 'sheet.rb'))

# Create a module to hold lib classes
module OptimizerLib
end

# Evaluate piece.rb in OptimizerLib context
OptimizerLib.module_eval(lib_piece_code.gsub(/^class (\w+)/, 'class OptimizerLib::\1'))

# Evaluate sheet.rb in OptimizerLib context  
OptimizerLib.module_eval(lib_sheet_code.gsub(/^class (\w+)/, 'class OptimizerLib::\1'))

# Now load other files normally
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require File.join(lib_path, 'guillotine_bin_packer')
require File.join(lib_path, 'cutting_optimizer')
require File.join(lib_path, 'input_loader')
require File.join(lib_path, 'step_parser')
require File.join(lib_path, 'linear_optimizer')
require File.join(lib_path, 'linear_report_generator')
require File.join(lib_path, 'report_generator')

