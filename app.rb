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

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments 
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_post INTEGER,
      Created_date DATE,
      Comment TEXT
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

get '/post/:post_id' do
  @post_id = params[:post_id]
  
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ? ORDER BY Created_date DESC', [@post_id]
  @results_comments = @db.execute 'SELECT * FROM Comments WHERE id_post = ? ORDER BY Created_date DESC', [@post_id]
 
  erb :post
end

post '/post/:post_id' do
  comment = params[ :comment]
  @post_id = params[:post_id]
  
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ? ORDER BY Created_date DESC', [@post_id]
  
  if comment.length <= 0
    @error = 'Type commet text'
    return :post
  end
  
  @db.execute 'INSERT INTO Comments (id_post, Comment, Created_date) VALUES( ?,?,datetime())', [@post_id, comment]
  @results_comments = @db.execute 'SELECT * FROM Comments WHERE id_post = ? ORDER BY Created_date DESC', [@post_id]
  
  #erb comment
  erb :post
  
end

