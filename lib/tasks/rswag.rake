require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:rswag_with_examples) do |t|
  t.pattern = ENV.fetch(
    'PATTERN',
    'spec/requests/**/*_spec.rb, spec/api/**/*_spec.rb, spec/integration/**/*_spec.rb'
  )
  t.rspec_opts = ['--format Rswag::Specs::SwaggerFormatter', '--order defined']
end

desc 'Generate Swagger JSON files from integration specs with examples'
task :rswag_with_examples do
  Rake::Task['rswag_with_examples'].invoke
end
