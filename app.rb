require 'sinatra'
require 'sinatra/cross_origin'
require 'harvested'


set :port, 3001

configure do
  enable :cross_origin
end


get '/projects/:id' do
  content_type :json
  harvest = Harvest.hardy_client(
    subdomain: ENV['HARVEST_SUBDOMAIN'],
    username:  ENV['HARVEST_USERNAME'],
    password:  ENV['HARVEST_PASSWORD']
  )
  project = nil
  entries = nil
  id = params['id'].sub! '.json', ''
  harvest.projects.all.each do |p|
    project = p
    if project.id.to_s == id
      entries = harvest.reports.time_by_project(project, Time.parse(project.hint_earliest_record_at), Time.parse(Date.today.strftime("%Y/%m/%d")) )
      break
    end

  end
  {entries: entries, project: project}.to_json
end
