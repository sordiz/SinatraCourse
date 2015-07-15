require 'mongo'
require 'shotgun'
require 'sinatra'

configure do
  enable :sessions
  client = Mongo::Client.new(["127.0.0.1:27017"], database: "test")
  set :mongo, client
end

class SampleApp < Sinatra::Application

  before do
    p "REQUEST FROM: " + request.host
  end

  get '/sumar/:a/:b' do
    (params[:a].to_i + params[:b].to_i).to_s
  end

  post '/add_post' do
    settings.mongo[:posts].insert_one(
      {"title"      => params[:title],
       "body"       => params[:body],
       "created_at" => Time.now})

    redirect '/'
  end

  get '/login' do
    session[:login_status] = "Logged"
  end

  get '/logout' do
    session[:login_status] = "Not logged"
  end

  get '/' do
    @posts = []
    settings.mongo[:posts].find.each do |doc|
      doc.delete_if {|key, value| key == "_id" }
      @posts << doc
    end
    erb 'posts'.to_sym
  end

  get '/inline/:name' do
    @name = params[:name]
    erb :inline_template
  end

  after do
    p "RESPONSE: " + response.to_s
  end
end

__END__

@@ layout
Login status: <%= session[:login_status] %>
</br>
<%= yield %>

@@ inline_template
Hello <%= @name %>, I am an Inline Template.
