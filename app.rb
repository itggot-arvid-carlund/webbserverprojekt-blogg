require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'
enable :session

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/create') do
    slim(:create)
end

post('/login') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT password, username FROM users WHERE username = (?)", params["username"])

    if params["username"] == result[0]["username"]
        if params["password"] == result[0]["password"]
        redirect('/welcome')
        
        else 
            redirect('/no_access')
        end
    else
    redirect('/no_access')
    end
    session[:username] = params["username"]
end

post('/create') do #JUUUSTERA!!!
    #ansluta till DB
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true

    # Plocka upp parametrarna ifrån formuläret
    new_username = params["username"]
    new_mail = params["mail"]
    new_password = params["password"]

    # Skicka iväg till databsen med SQL
    db.execute("INSERT INTO users (username,mail,password) VALUES (?,?,?)",new_username,new_mail,new_password)

    #Redirect till anann GET
    redirect('/')
end