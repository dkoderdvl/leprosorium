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
      Author_name TEXT,
      Content TEXT
    )'

  @db.execute 'CREATE TABLE IF NOT EXISTS Comments 
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_post INTEGER,
      Author_name TEXT,
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
  hh_invalid = {
    :author_name => 'Enter your name',
    :content => 'Type post text'
    }
  @error = hh_invalid.select {|k,v| params[k].strip == '' }.values.join ', '
  
  return erb :new if @error.length > 0
  
  content = params[ :content]
  author_name = params[ :author_name ]
 
  @db.execute 'INSERT INTO Posts (Author_name, Content, Created_date) VALUES( ?,?,datetime())', [author_name, content]
  
  redirect to '/'
  
end

get '/post/:post_id' do
  @post_id = params[:post_id]
  
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ? ORDER BY Created_date DESC', [@post_id]
  @results_comments = @db.execute 'SELECT * FROM Comments WHERE id_post = ? ORDER BY Created_date DESC', [@post_id]
 
  erb :post
end

post '/post/:post_id' do
  hh_invalid = {
    :author_name => 'Enter your name',
    :comment => 'Type comment text'
    }
  @error = hh_invalid.select{|k,v| params[k].strip == ''}.values.join ', '
  
  @post_id = params[:post_id]
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ? ORDER BY Created_date DESC', [@post_id]
  @results_comments = @db.execute 'SELECT * FROM Comments WHERE id_post = ? ORDER BY Created_date DESC', [@post_id]

  return erb :post if @error.length > 0
  
  comment = params[ :comment]
  author_name = params[:author_name]
  
  
  @db.execute 'INSERT INTO Comments (id_post, Author_name, Comment, Created_date) VALUES( ?,?,?,datetime())', [@post_id, author_name, comment]
  @results_comments = @db.execute 'SELECT * FROM Comments WHERE id_post = ? ORDER BY Created_date DESC', [@post_id]
  
  erb :post
end
