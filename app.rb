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
    result = db.execute("SELECT username, password FROM users WHERE username = ?", params["username"])
    if result.length > 0
        banan = result[0]
    else
        banan = [[]]
    end
    if params["username"] == banan[0]
        if params["password"] == banan[1]
        redirect('/welcome')
        
        else 
            redirect('/login')
        end
    else
    redirect('/login')
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