namespace :revenue do
  desc "load initial rates for active projects"
  task :initial => :environment do
    project_rates = {}
    project_rates[173] = { investment_fridays: true, rates: { 'Developer' => 6400, 'Designer' => 6400, 'Principal' => 11200, 'Product Manager' => 0 } }
    project_rates[172] = { investment_fridays: true, rates: { 'Developer' => 2000, 'Designer' => 2000 } }
    project_rates[134] = { investment_fridays: false, rates: { 'Developer' => 7200, 'Designer' => 5400, 'Principal' => 7200, 'Product Manager' => 5400 } }
    project_rates[205] = { investment_fridays: false, rates: { 'Developer' => 7200, 'Principal' => 14400, 'Product Manager' => 7200 } }
    project_rates[168] = { investment_fridays: false, rates: { 'Developer' => 9000, 'Designer' => 9250, 'Principal' => 15300 } }
    project_rates[203] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000 } }
    project_rates[195] = { investment_fridays: false, rates: { 'Developer' => 7400, 'Designer' => 7400, 'Principal' => 12000 } }
    project_rates[193] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000, 'Principal' => 8000 } }
    project_rates[196] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000, 'Principal' => 16000 } }
    project_rates[199] = { investment_fridays: false, rates: { 'Developer' => 7000, 'Designer' => 7000, 'Principal' => 14000 } }
    project_rates[201] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000 } }
    project_rates[179] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000 } }
    project_rates[204] = { investment_fridays: false, rates: { 'Developer' => 8000, 'Designer' => 8000, 'Principal' => 16000 } }
    project_rates[73]  = { investment_fridays: false, rates: { 'Developer' => 7360, 'Principal' => 0 } }
    project_rates[200] = { investment_fridays: true, rates: { 'Developer' => 6000, 'Designer' => 6000, 'Principal' => 12000 } }
    project_rates[87]  = { investment_fridays: true, rates: { 'Developer' => 5938, 'Designer' => 5938, 'Product Manager' => 5937.5 } }
    project_rates[197] = { investment_fridays: false, rates: { 'Developer' => 7200, 'Designer' => 7200, 'Principal' => 11200 } }
    project_rates[105] = { investment_fridays: false, rates: { 'Developer' => 6752, 'Designer' => 0, 'Principal' => 6752 } }
    project_rates[83]  = { investment_fridays: false, rates: { 'Principal' => 14000 } }
    project_rates[160] = { investment_fridays: true, rates: { 'Developer' => 5600, 'Designer' => 5600, 'Principal' => 12000 } }
    project_rates[191] = { investment_fridays: true, rates: { 'Developer' => 5834 } }
    project_rates[180] = { investment_fridays: true, rates: { 'Developer' => 5760 } }

    project_rates.keys.each do |project_id|
      project = Project.find(project_id)
      project.investment_fridays = project_rates[project_id][:investment_fridays]
      project.rates = project_rates[project_id][:rates]
      project.save!
    end
  end
end
