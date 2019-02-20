#encoding: utf-8


require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.sqlite'
  @db.results_as_hash = true
end

configure do
  init_db

  @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Created_date DATE,
      Content TEXT
    )'

end

before do   
  init_db  
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY Created_date DESC'
  
  erb :posts
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[ :content]
  
  if content.length <= 0
    @error = 'Type post text'
    return :new
  end
  
  @db.execute 'INSERT INTO Posts (Content, Created_date) VALUES( ?,datetime())', [content]
  
  redirect to '/'
  
end

get '/post/*' do
  @id_post = request.path[6..request.path.length].to_i
 
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ? ORDER BY Created_date DESC', [@id_post]
 
  
  #erb "#{id}"
  erb :post
end
