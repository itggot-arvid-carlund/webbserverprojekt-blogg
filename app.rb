require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'
require 'BCrypt'
enable :sessions

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/create') do
    slim(:create)
end

get('/welcome') do
    slim(:welcome)
end

get('/profile/:id') do
    if session[:loggedin] == true
    slim(:profile)
    else
        redirect('/login')
    end
end

post('/login') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT username, password, id FROM users WHERE username = ?", params["username"])
    if result.length > 0 && BCrypt::Password.new(result.first["password"]) == params["password"]
        session[:username] = result.first["username"]
        session[:id] = result.first["id"]
        p result
        session[:loggedin] = true
        p  session[:id]
        redirect("/profile/#{session[:id]}")
    else 
        redirect('/')
    end
end

post('/create') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true

    hased_password = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO users (username,password) VALUES (?,?)",params["username"], hased_password)
    redirect('login')
end

#List Posts
get('/profile') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true

     result = db.execute("SELECT blogg.Title, blogg.Date, blogg.Text, blogg.Id, from blogg")

     slim(:users, locals:{ users: result})
end

#CREATE
post('/blogg_create') do
    #ansluta till DB
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true

    # Plocka upp parametrarna ifrån formuläret
    new_Title = params["Title"]
    new_Text = params["Text"]
    new_Date = params["Date"]

    # Skicka iväg till databsen med SQL
    db.execute("INSERT INTO blogg (Title,Text,Date,) VALUES (?,?,?)",new_Title,new_Text,new_Date)

    #Redirect till anann GET
    redirect('/profile')
end

#EDIT USERS
get('/users/:id/edit') do
    slim(:edit_user)
end

post('/users/:id/edit_user') do
    db = SQLite3::Database.new("db/users.db")
    db.execute("UPDATE users SET name = ?, email = ?, tel = ?, department_id = ? WHERE id = ?",params["name"],params["email"],params["tel"], params["department"], params["id"])
    redirect(:users)
end