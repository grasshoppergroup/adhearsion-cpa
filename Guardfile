guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/adhearsion_cpa/(.+)\.rb$})     { |m| "spec/adhearsion_cpa/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
